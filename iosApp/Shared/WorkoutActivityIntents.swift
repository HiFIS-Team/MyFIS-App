import ActivityKit
import AppIntents

// 잠금화면 · 다이내믹 아일랜드의 버튼 둘.
//
// **두 타깃에 다 들어간다.** 확장은 버튼을 그리려고 타입만 알면 되고, 실제 일은 **앱 프로세스**에서 한다
// (`LiveActivityIntent` — 앱이 멈춰 있으면 시스템이 깨워서 부른다).
// 확장에는 세션 저장소가 없어서 몸통을 `MYFIS_LIVE_ACTIVITY` 로 가른다

/// `⏸` / `▶` — **세션 전체가 같이 선다** (화면의 재생 버튼과 같다)
struct SessionToggleIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "일시정지 또는 이어서 하기"

    func perform() async throws -> some IntentResult {
        #if !MYFIS_LIVE_ACTIVITY
        await MainActor.run { WorkoutSessionStore.shared.toggle() }
        #endif
        return .result()
    }
}

/// `⏭` — 다음 단계로 (화면의 다음 버튼과 같다)
struct SessionNextIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "다음 단계로"

    func perform() async throws -> some IntentResult {
        #if !MYFIS_LIVE_ACTIVITY
        await MainActor.run { WorkoutSessionStore.shared.next() }
        #endif
        return .result()
    }
}
