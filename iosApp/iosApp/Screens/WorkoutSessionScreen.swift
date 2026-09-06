import SwiftUI

// MARK: - 모델

/// 세션의 두 마디 — 웜업은 **시간**으로, 운동은 **분량**으로 센다
enum SessionStage {
    case warmup, workout
}

/// 세션의 한 단계.
///
/// 웜업이면 `seconds` 가, 운동이면 `exercise` 가 찬다. 둘 다 차는 일은 없다.
struct SessionStep: Identifiable {
    let id: Int
    let title: String
    let stage: SessionStage
    var seconds: Int?
    var exercise: RoutineExercise?
}

/// TODO(서버): 루틴 API 가 붙으면 이 순서를 받아온다.
///
/// **W-01 과 같은 목록을 쓴다** — 웜업 다섯 개가 먼저고 그다음이 운동이다 (금지 6).
enum WorkoutSessionPlaceholder {
    /// 웜업 한 개에 주는 시간 — 다섯 개로 `warmupMinutes` 분이 된다
    static let warmupSeconds = RoutinePlaceholder.warmupMinutes * 60 / RoutinePlaceholder.warmup.count

    static let steps: [SessionStep] = {
        let warmup = RoutinePlaceholder.warmup.enumerated().map { index, name in
            SessionStep(id: index, title: name, stage: .warmup, seconds: warmupSeconds)
        }
        let workout = RoutinePlaceholder.exercises.enumerated().map { index, item in
            SessionStep(id: warmup.count + index, title: item.name,
                        stage: .workout, exercise: item)
        }
        return warmup + workout
    }()
}

private func mmss(_ seconds: Int) -> String {
    String(format: "%02d:%02d", seconds / 60, seconds % 60)
}

// MARK: - 화면

/// SPEC.md W-04 **운동 세션** 🟡 틀 (DESIGN.md §6.37)
///
/// 레퍼런스는 사용자가 준 다른 앱의 세션 화면이다 — **재생기**다.
/// 위에서 아래로 *지금 뭘 하나 · 어떻게 하나 · 얼마나 남았나 · 다음은 뭔가 · 조작*.
///
/// **원본에서 뺀 것**
/// - 위쪽 `⏸` — 아래 재생 버튼과 **같은 일을 두 번** 말한다. 조작은 아래 한 줄이 다 맡는다
/// - 톱니(설정) — 갈 곳이 없다. 갈 곳이 생기면 그때 단다
/// - 민트 점 · 민트 `다음 운동` 라벨 — 원본은 색이 다섯 곳이다. 우리는 **재생 버튼 하나**뿐이다 (§3.2)
///
/// ⚠️ **연출을 넣지 않는다** (ui-design 스킬) — 운동 중 화면은 북극성과 충돌한다.
struct WorkoutSessionScreen: View {
    let onExit: () -> Void
    /// 마지막 단계를 넘기면 — TODO(W-05): 완료 화면으로 간다
    var onFinish: () -> Void

    private let steps = WorkoutSessionPlaceholder.steps

    @State private var index = 0
    @State private var remain = WorkoutSessionPlaceholder.steps[0].seconds ?? 0
    @State private var elapsed = 0
    @State private var playing = true
    /// TODO(W-04): 음성 렙 카운트가 붙으면 이 스위치가 그걸 끈다
    @State private var voice = true

    /// ⚠️ `let` 으로 두면 **부모가 다시 그릴 때마다 새 퍼블리셔**가 생겨 구독이 갈아 끼워지고,
    /// 1초 간격이 그때마다 처음부터 다시 시작한다. `@State` 는 처음 값만 남긴다
    @State private var tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var step: SessionStep { steps[index] }
    private var next: SessionStep? { index + 1 < steps.count ? steps[index + 1] : nil }

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(alignment: .leading, spacing: 0) {
                Text(stageLabel)
                    .font(MyFisFont.bodySm)
                    .foregroundStyle(MyFisColor.textSecondary)
                Text(step.title)
                    .font(MyFisFont.titleLg)
                    .foregroundStyle(MyFisColor.textPrimary)
                    .lineLimit(1)
                    .padding(.top, MyFisSpacing.xs)

                // 시연 그림은 **남는 자리를 다 쓴다.** 이 화면은 스크롤하지 않는다 —
                // 운동 중에는 손이 젖어 있고, 필요한 것이 전부 한 판에 있어야 한다
                demoStage
                    .padding(.top, MyFisSpacing.lg)

                stepPanel
                    .padding(.top, MyFisSpacing.lg)
                nextCard
                    .padding(.top, MyFisSpacing.lg)
            }
            .padding(.horizontal, MyFisSpacing.screenHorizontal)

            controls
                .padding(.horizontal, MyFisSpacing.screenHorizontal)
                .padding(.top, MyFisSpacing.lg)
                .padding(.bottom, MyFisSpacing.xxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onReceive(tick) { _ in advance() }
        // **세트 사이에 화면이 꺼지면 매번 깨워야 한다** (SPEC W 공통 규칙)
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // MARK: - 흐름

    /// 재생 중일 때만 흐른다. 웜업은 남은 시간이 0 이 되면 **스스로 넘어간다**
    private func advance() {
        guard playing else { return }
        elapsed += 1
        guard step.seconds != nil else { return }
        if remain > 1 { remain -= 1 } else { move(to: index + 1) }
    }

    private func move(to target: Int) {
        guard target <= steps.count - 1 else {
            onFinish()
            return
        }
        let safe = max(0, target)
        index = safe
        remain = steps[safe].seconds ?? 0
    }

    /// `웜업 스트레칭 1 / 5` · `운동 2 / 6` — 지금 몇 번째인지 (마디 안에서 센다)
    private var stageLabel: String {
        let stage = step.stage
        let within = steps.prefix(index + 1).filter { $0.stage == stage }.count
        let total = steps.filter { $0.stage == stage }.count
        return "\(stage == .warmup ? "웜업 스트레칭" : "운동") \(within) / \(total)"
    }

    // MARK: - 조각

    /// `←` · **총 경과 시간** · 음성 가이드.
    ///
    /// 잎 화면이라 `DetailHeader` 를 쓰고 싶지만 그건 *왼쪽 아이콘 · 가운데 제목 · 오른쪽 아이콘*
    /// 셋뿐이다. 여기는 **왼쪽 아이콘 옆에 숫자**가 붙는다 — 높이(56)와 좌우 여백은 그대로 맞춘다 (§6.9)
    private var header: some View {
        HStack(spacing: 0) {
            HeaderIcon("ic_tab_back", "세션 나가기", action: onExit)
            // 자릿수가 늘어도(`59:59` → `1:00:00`) 안 흔들려야 한다 — metric 은 tnum 이다
            Text(mmss(elapsed))
                .font(MyFisFont.metricMd)
                .foregroundStyle(MyFisColor.textPrimary)
                .padding(.leading, MyFisSpacing.sm)

            Spacer(minLength: MyFisSpacing.md)

            voiceChip
        }
        .frame(height: MyFisSize.header)
        .padding(.horizontal, MyFisSpacing.screenHorizontal - MyFisSpacing.sm)
    }

    /// 끈 상태는 **색으로 죽인다** — 투명도를 쓰지 않는다 (§9 이탈 #2)
    private var voiceChip: some View {
        Button { voice.toggle() } label: {
            HStack(spacing: MyFisSpacing.sm) {
                Image("ic_session_voice")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 18, height: 18)
                Text("음성 가이드")
                    .font(MyFisFont.label)
            }
            .foregroundStyle(voice ? MyFisColor.textPrimary : MyFisColor.textTertiary)
            .padding(.horizontal, MyFisSpacing.md)
            .frame(height: MyFisSize.chip)
        }
        // **면은 스타일 밖에 둔다** — 그래야 판은 가만히 있고 속만 줄어든다 (§6.7).
        // 누르는 동안 아무 변화가 없으면 손을 뗄 때까지 아무 일도 안 한 것처럼 느껴진다
        .buttonStyle(.myFisIcon)
        .background(voice ? MyFisColor.surface2 : MyFisColor.surface1, in: Capsule())
        .accessibilityLabel(voice ? "음성 가이드 끄기" : "음성 가이드 켜기")
    }

    /// 시연 그림 자리 — W-03(§6.36)과 **같은 자리 표시**다.
    ///
    /// TODO(WorkoutX): `gifUrl` 을 건다 (SPEC §7.7). ⚠️ 배경이 흰색일 수 있다 (열린 질문 17-1)
    private var demoStage: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MyFisColor.surface2,
                        in: RoundedRectangle(cornerRadius: MyFisRadius.lg, style: .continuous))
            .overlay {
                Image("ic_tab_weight")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 96, height: 96)
                    .foregroundStyle(MyFisColor.surface3)
            }
    }

    /// 이 화면의 **1순위** (§2 원칙 1) — 웜업은 *남은 시간*, 운동은 *분량*이다.
    ///
    /// 마디마다 재는 것이 다르다. 웜업은 시간이 끝나면 저절로 넘어가고,
    /// 운동은 몇 번을 드느냐가 전부라 시계가 할 말이 없다
    private var stepPanel: some View {
        // 숫자 카드(§6.3)와 같은 판이다 — 직접 그리지 않고 `MyFisCard` 를 쓴다 (금지 1)
        MyFisCard {
            VStack(spacing: MyFisSpacing.xs) {
                if step.stage == .warmup {
                    Text(mmss(remain))
                        .font(MyFisFont.metricXl)
                        .foregroundStyle(MyFisColor.textPrimary)
                } else {
                    // 라벨 위 · 값 아래 — 숫자 카드(§6.3)와 같은 읽는 순서다
                    Text("\(step.exercise?.sets ?? 0)세트")
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textSecondary)
                    Text([step.exercise?.load, "\(step.exercise?.reps ?? 0)회"]
                        .compactMap { $0 }.joined(separator: " × "))
                        .font(MyFisFont.metricLg)
                        .foregroundStyle(MyFisColor.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MyFisSpacing.xs)
        }
    }

    /// 다음에 뭐가 오는지. 마지막이면 **자리는 그대로 두고 말만 바꾼다** — 카드가 사라지면 아래가 튄다
    private var nextCard: some View {
        MyFisCard {
            HStack(spacing: MyFisSpacing.md) {
                MyFisIconTile(dimmed: next == nil) {
                    Image(next?.exercise?.gear.icon ?? RoutineGear.stretch.icon)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(MyFisColor.textSecondary)
                }
                VStack(alignment: .leading, spacing: MyFisSpacing.xs) {
                    Text(next == nil ? "마지막" : "다음")
                        .font(MyFisFont.label)
                        .foregroundStyle(MyFisColor.textSecondary)
                    Text(next?.title ?? "이걸로 끝이에요")
                        .font(MyFisFont.titleSm)
                        .foregroundStyle(MyFisColor.textPrimary)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
        }
    }

    /// 조작 한 줄 — 이전 · 재생/일시정지 · 다음.
    ///
    /// **재생이 세션 전체를 멈춘다** (총 경과 시간과 웜업 시계가 같이 선다).
    /// 원본은 이걸 위아래 두 곳에 뒀는데 같은 일을 두 번 말하는 것이라 아래로 모았다.
    ///
    /// 가운데만 Primary 다 — 이 화면에서 **액센트는 이 하나뿐**이다 (§3.2)
    private var controls: some View {
        HStack(spacing: MyFisSpacing.md) {
            MyFisSecondaryButton(title: "이전", tall: true, icon: "ic_session_prev") {
                move(to: index - 1)
            }
            MyFisPrimaryButton(title: playing ? "일시정지" : "이어서 하기",
                               icon: playing ? "ic_session_pause" : "ic_session_play") {
                playing.toggle()
            }
            MyFisSecondaryButton(title: "다음", tall: true, icon: "ic_session_next") {
                move(to: index + 1)
            }
        }
    }
}

#Preview {
    WorkoutSessionScreen(onExit: {}, onFinish: {}).preferredColorScheme(.dark)
}
