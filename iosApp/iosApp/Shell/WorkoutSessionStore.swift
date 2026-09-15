import ActivityKit
import Foundation
import Observation
import SharedKit

/// 지금 시각 (epoch ms) — `SessionClock` 은 시각을 밖에서 받는다
func nowMillis() -> Int64 {
    Int64(Date().timeIntervalSince1970 * 1000)
}

/// 잠금화면 버튼 진단 (DEBUG 전용) — 폰에서 `devicectl device process launch --console` 로 본다.
///
/// 2026-09-15 *"멈춤이 안 되고 느리게 바뀐다"* 를 재려고 넣었다. 버튼을 받은 시각 · 시계가 바뀐 시각 ·
/// 잠금화면 갱신이 끝난 시각을 찍는다. `stderr` 라 버퍼에 갇히지 않는다
func sessionTrace(_ message: String) {
    #if DEBUG
    let stamp = String(format: "%.3f", Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 100))
    fputs("[session \(stamp)] \(message)\n", stderr)
    #endif
}

/// 운동 세션(W-04)의 **화면 밖 저장소** (DESIGN §6.37 · SPEC W-04).
///
/// 세션 화면 · 잠금화면(라이브 액티비티) · 잠금화면 버튼 셋이 **같은 시계**를 본다.
/// 버튼은 앱 프로세스에서 `LiveActivityIntent` 로 들어오므로, 시계가 화면 `@State` 에 있으면 닿을 수 없다.
///
/// - 라이브 액티비티는 **바뀔 때만** 갱신한다 — 단계 · 재생 여부 · 끝남. 시계는 시스템이 흘린다
/// - ⚠️ 폰이 잠겨 앱이 멈춰 있으면 **웜업 자동 넘김이 잠금화면에 반영되지 않는다.**
///   카운트다운이 0 에서 서고, 앱이 깨어나는 순간(`tick`) 따라잡아 갱신한다
/// - 저장소는 메모리다. 앱이 죽으면 세션도 없어지므로, 다음에 뜰 때 남은 잠금화면을 치운다 (`endOrphans`)
@MainActor
@Observable
final class WorkoutSessionStore {
    static let shared = WorkoutSessionStore()

    /// 마지막 세션의 시계. **닫힌 뒤에도 남긴다** — 화면이 밀려 나가는 동안 마지막 모습을 그려야 한다
    private(set) var clock: SessionClock?
    /// 세션이 열려 있다 (화면이 떠 있다)
    private(set) var isRunning = false
    /// 음성 가이드 켜짐 — 세션 화면 칩이 바꾼다. 세션을 열 때마다 켜진 채로 시작한다
    private(set) var voiceOn = true

    /// 음성 가이드 (§6.37) — 말은 `SessionVoiceScript`, 언제 말할지는 여기(`speak`)가 정한다
    @ObservationIgnored private let voice = SessionVoice()
    /// 이 단계에서 이미 센 숫자 — 멈췄다 이어도 같은 숫자를 두 번 세지 않는다
    @ObservationIgnored private var countedDown: CountMark?

    @ObservationIgnored private var steps: [SessionStep] = []
    @ObservationIgnored private var activity: Activity<WorkoutActivityAttributes>?
    /// 마지막으로 보낸 잠금화면 갱신 — 잠금화면 버튼은 **이게 끝날 때까지 기다린다** (`synced`)
    @ObservationIgnored private var pendingSync: Task<Void, Never>?

    /// 완료 요약을 잠금화면에 남기는 시간
    private static let summaryLinger: TimeInterval = 15 * 60

    private init() {}

    /// 새 세션을 연다. 남아 있던 잠금화면은 걷고 새로 띄운다
    func start(_ steps: [SessionStep]) {
        self.steps = steps
        let now = nowMillis()
        let clock = SessionClock.companion.start(
            stepSeconds: steps.map { KotlinInt(int: Int32($0.seconds ?? 0)) },
            now: now
        )
        self.clock = clock
        isRunning = true
        voiceOn = true
        countedDown = nil
        voice.say(entering(0))
        endActivity(state: nil, dismissal: .immediate)
        startActivity(state(clock, now: now))
    }

    /// 틱마다 — 시간이 다 된 웜업을 넘긴다
    func tick() { apply { $0.catchUp(now: $1) } }

    func toggle() { apply { $0.toggle(now: $1) } }

    /// 잠금화면 `⏸` `▶` — 뒤집지 않고 **값으로** 둔다. 늦게 바뀌어 여러 번 눌러도 결과가 같다
    func setPlaying(_ playing: Bool) { apply { playing ? $0.resume(now: $1) : $0.pause(now: $1) } }

    func next() { apply { $0.next(now: $1) } }

    func previous() { apply { $0.previous(now: $1) } }

    /// 화면이 닫힐 때. **끝나서 닫히면** 요약은 이미 남겼으니 두고, 중간에 나가면 바로 걷는다
    func close() {
        guard isRunning else { return }
        isRunning = false
        // 끝나서 닫히면 `오늘 운동을 마쳤어요` 를 끝까지 읽게 둔다
        if clock?.finished != true {
            voice.stop()
            endActivity(state: nil, dismissal: .immediate)
        }
    }

    // MARK: - 음성 가이드

    func toggleVoice() {
        voiceOn.toggle()
        if !voiceOn { voice.stop() }
    }

    /// 시계가 바뀔 때마다 — **끝남 · 단계 바뀜 · 웜업 끝 3초** 에만 말한다. 멈춤 · 이어서는 말하지 않는다
    private func speak(from old: SessionClock, to new: SessionClock, now: Int64) {
        guard voiceOn else { return }
        if new.finished && !old.finished {
            voice.say(SessionVoiceScript.shared.FINISHED)
        } else if new.index != old.index {
            countedDown = nil
            voice.say(entering(Int(new.index)))
        } else if new.isTimed && new.isPlaying {
            let mark = CountMark(index: Int(new.index), remain: Int(new.remainSeconds(now: now)))
            guard mark != countedDown,
                  let word = SessionVoiceScript.shared.countdown(remainSeconds: Int32(mark.remain)) else { return }
            countedDown = mark
            voice.say(word)
        }
    }

    private func entering(_ index: Int) -> String {
        let step = steps[index]
        let position = sessionStagePosition(steps, index)
        return SessionVoiceScript.shared.entering(
            warmup: step.stage == .warmup,
            within: Int32(position.within),
            total: Int32(position.total),
            title: step.title,
            seconds: Int32(step.seconds ?? 0),
            sets: Int32(step.exercise?.sets ?? 0),
            load: step.exercise?.load,
            reps: Int32(step.exercise?.reps ?? 0)
        )
    }

    private struct CountMark: Equatable {
        let index: Int
        let remain: Int
    }

    /// 보낸 잠금화면 갱신이 **시스템에 닿을 때까지** 기다린다.
    ///
    /// ⚠️ 잠금화면 버튼(`LiveActivityIntent`)은 앱을 잠깐 깨워 부른다. 갱신을 걸어 두기만 하고 바로 돌아가면
    /// iOS 가 앱을 다시 재워서 **갱신이 늦게 가거나 안 갔다** — 앱은 멈췄는데 잠금화면 시계는 계속 흘렀다 (2026-09-15 실기)
    func synced() async {
        await pendingSync?.value
    }

    /// 앱이 뜰 때 — 지난번에 앱이 죽으며 남긴 잠금화면을 치운다
    func endOrphans() {
        for orphan in Activity<WorkoutActivityAttributes>.activities where orphan.id != activity?.id {
            Task { await orphan.end(nil, dismissalPolicy: .immediate) }
        }
    }

    // MARK: - 시계

    private func apply(_ change: (SessionClock, Int64) -> SessionClock) {
        guard isRunning, let old = clock else { return }
        let now = nowMillis()
        let updated = change(old, now)
        clock = updated
        speak(from: old, to: updated, now: now)
        if updated.index != old.index || updated.isPlaying != old.isPlaying || updated.finished != old.finished {
            sessionTrace("시계 바뀜 — 흐름 \(old.isPlaying)→\(updated.isPlaying) · 단계 \(old.index)→\(updated.index) · " +
                         "잠금화면 \(activity == nil ? "없음" : "있음")")
        }
        if updated.finished && !old.finished {
            endActivity(state: state(updated, now: now),
                        dismissal: .after(Date().addingTimeInterval(Self.summaryLinger)))
        } else if updated.index != old.index || updated.isPlaying != old.isPlaying {
            updateActivity(state(updated, now: now))
        }
    }

    /// 시계에서 **그릴 값만** 뽑는다. 시간은 시각으로 — 확장에서 시스템이 흘린다
    private func state(_ clock: SessionClock, now: Int64) -> WorkoutActivityAttributes.ContentState {
        let index = Int(clock.index)
        let step = steps[index]
        let position = sessionStagePosition(steps, index)
        // 시계가 선 시각 — 멈춰 있으면 멈춘 시각, 아니면 지금
        let reference = clock.isPlaying ? now : clock.pausedAt

        var warmupFrom: Date?
        var warmupUntil: Date?
        if clock.isTimed, let seconds = step.seconds {
            let until = reference + clock.remainMillis(now: now)
            warmupUntil = date(until)
            warmupFrom = date(until - Int64(seconds) * 1000)
        }

        return .init(
            stageLabel: "\(position.name) \(position.within) / \(position.total)",
            progress: "\(position.within)/\(position.total)",
            title: step.title,
            load: step.exercise?.loadAndReps,
            nextTitle: index + 1 < steps.count ? steps[index + 1].title : nil,
            elapsedFrom: date(reference - clock.elapsed(now: now)),
            warmupFrom: warmupFrom,
            warmupUntil: warmupUntil,
            pausedAt: clock.isPlaying ? nil : date(clock.pausedAt),
            finishedSeconds: clock.finished ? Int(clock.elapsedSeconds(now: now)) : nil
        )
    }

    private func date(_ millis: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(millis) / 1000)
    }

    // MARK: - 라이브 액티비티

    private func startActivity(_ state: WorkoutActivityAttributes.ContentState) {
        // 설정에서 라이브 액티비티를 껐으면 조용히 넘어간다 — 세션 화면은 그대로 돈다
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        do {
            activity = try Activity.request(
                attributes: WorkoutActivityAttributes(),
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("[WorkoutSessionStore] 라이브 액티비티 시작 실패: \(error)")
        }
    }

    private func updateActivity(_ state: WorkoutActivityAttributes.ContentState) {
        guard let activity else { return }
        let sent = Date()
        pendingSync = Task {
            await activity.update(.init(state: state, staleDate: nil))
            sessionTrace("잠금화면 갱신 끝 — \(Int(Date().timeIntervalSince(sent) * 1000))ms · 멈춤 \(state.pausedAt != nil)")
        }
    }

    private func endActivity(state: WorkoutActivityAttributes.ContentState?,
                             dismissal: ActivityUIDismissalPolicy) {
        guard let activity else { return }
        self.activity = nil
        pendingSync = Task {
            await activity.end(state.map { .init(state: $0, staleDate: nil) }, dismissalPolicy: dismissal)
        }
    }
}
