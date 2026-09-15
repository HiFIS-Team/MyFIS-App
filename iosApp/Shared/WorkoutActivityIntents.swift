import ActivityKit
import AppIntents

// 잠금화면 · 다이내믹 아일랜드의 버튼 둘.
//
// **두 타깃에 다 들어간다.** 확장은 버튼을 그리려고 타입만 알면 되고, 실제 일은 **앱 프로세스**에서 한다
// (`LiveActivityIntent` — 앱이 멈춰 있으면 시스템이 깨워서 부른다).
// 확장에는 세션 저장소가 없어서 몸통을 `MYFIS_LIVE_ACTIVITY` 로 가른다

/// `⏸` / `▶` — **멈춰라 / 흘러라를 값으로 싣는다** 🟢 (2026-09-15 실기).
///
/// ⚠️ 처음엔 *뒤집기*(toggle)였다. 버튼 반응이 늦어 한 번 더 누르면 멈춤 → 재생으로 **두 번 뒤집혀**
/// 멈춤이 안 먹는 것처럼 보였다 (건너뛰기는 두 번 눌러도 앞으로만 가서 멀쩡해 보였다).
/// 값을 실으면 여러 번 눌러도 결과가 같다
struct SessionPlayIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "일시정지 또는 이어서 하기"

    /// `true` 면 흐르게, `false` 면 멈추게
    @Parameter(title: "흐르게", default: false)
    var playing: Bool

    init() {}

    init(playing: Bool) {
        self.playing = playing
    }

    func perform() async throws -> some IntentResult {
        #if !MYFIS_LIVE_ACTIVITY
        let playing = playing
        sessionTrace("버튼 play(\(playing)) 받음")
        await MainActor.run { WorkoutSessionStore.shared.setPlaying(playing) }
        // 잠금화면 갱신이 닿기 전에 돌아가면 iOS 가 앱을 재워 늦게 바뀐다 — 끝날 때까지 기다린다
        await WorkoutSessionStore.shared.synced()
        sessionTrace("버튼 play(\(playing)) 끝")
        #endif
        return .result()
    }
}

/// `⏭` — 다음 단계로 (화면의 다음 버튼과 같다)
struct SessionNextIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "다음 단계로"

    func perform() async throws -> some IntentResult {
        #if !MYFIS_LIVE_ACTIVITY
        sessionTrace("버튼 next 받음")
        await MainActor.run { WorkoutSessionStore.shared.next() }
        await WorkoutSessionStore.shared.synced()
        sessionTrace("버튼 next 끝")
        #endif
        return .result()
    }
}
