import ActivityKit
import Foundation

/// 운동 세션(W-04)의 **잠금화면 · 다이내믹 아일랜드** 자료 — 앱과 확장(`MyFISLiveActivity`)이 같이 쓴다.
///
/// 확장은 `SharedKit`(Kotlin)을 링크하지 않는다. 앱이 `SessionClock` 에서 **그릴 값만 뽑아** 여기 담아 보낸다.
/// 시간은 숫자가 아니라 **시각**으로 보낸다 — 앱이 멈춰 있어도 시스템이 흘린다 (`Text(timerInterval:)`)
struct WorkoutActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// `웜업 스트레칭 1 / 5` · `운동 2 / 6`
        var stageLabel: String
        /// 아일랜드 작은 자리 — `1/5` · `2/6`
        var progress: String
        var title: String
        /// 운동이면 `20kg × 12회`. 웜업이면 `nil` — 그 자리에 남은 시간이 온다
        var load: String?
        /// 다음 단계 이름. 마지막이면 `nil`
        var nextTitle: String?
        /// 총 경과가 0 이던 시각 (`지금 − 경과`)
        var elapsedFrom: Date
        /// 웜업 카운트다운 범위. 운동이면 `nil`
        var warmupFrom: Date?
        var warmupUntil: Date?
        /// 멈춘 시각. 흐르는 중이면 `nil` — 두 시계가 이 시각에 선 채로 보인다
        var pausedAt: Date?
        /// 끝났으면 총 경과(초). 요약 한 줄에 쓴다
        var finishedSeconds: Int?

        var isWarmup: Bool { warmupUntil != nil }
        var isFinished: Bool { finishedSeconds != nil }
    }
}
