import SwiftUI

/// DESIGN.md §5.1 간격 — 4pt 베이스
enum MyFisSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let huge: CGFloat = 40
    static let giant: CGFloat = 56

    /// 화면 좌우 여백
    static let screenHorizontal: CGFloat = 20
    /// 카드 내부 패딩
    static let cardPadding: CGFloat = 16
    /// 카드 사이 간격
    static let cardGap: CGFloat = 12
    /// 섹션 사이 간격
    static let sectionGap: CGFloat = 32
}

/// DESIGN.md §5.2 라운딩
enum MyFisRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    /// 아이콘 판 (§6.23 혜택 행) — `56` 판에 맞춘 값이다. 다른 크기에 그대로 쓰지 않는다
    static let tile: CGFloat = 18
    /// 그 `18 / 56`. 판 크기가 다르면 이 비율로 다시 뽑는다 (§6.26 · 2026-09-04)
    static let tileRatio: CGFloat = tile / MyFisSize.listRowMin
    static let full: CGFloat = 999
}

/// DESIGN.md §5.3 터치 타겟 / §6.1 버튼 높이
enum MyFisSize {
    static let minTouchTarget: CGFloat = 44
    static let buttonPrimary: CGFloat = 52
    static let buttonSecondary: CGFloat = 44
    static let inputHeight: CGFloat = 52
    /// 큰 찾기 줄 (M-08) — 입력 필드보다 크다. **화면에서 제일 먼저 눈에 들어와야** 한다
    static let searchBar: CGFloat = 64
    static let listRowMin: CGFloat = 56
    static let progressHeight: CGFloat = 8
    /// 카드 안 보조 버튼 (§6.1)
    static let buttonSmall: CGFloat = 36

    /// 알약 칩·뱃지 높이 (§5.2) — 마일리지 칩 · 연속 출석 · 펼쳐보기 · 도움 됐어요.
    ///
    /// **`buttonSmall` 과 같은 값이다.** 숫자를 새로 만든 게 아니라 이름을 준 것 —
    /// 칩과 Small 버튼은 나란히 서는 일이 있어 높이가 같아야 한다.
    ///
    /// ⚠️ 전에는 세로 여백(`6`·`7`)으로 높이를 만들었는데 그 값이 §5.1 스케일 밖이었다.
    /// 높이를 못 박으면 글꼴이나 아이콘이 바뀌어도 칩이 안 흔들린다 (2026-08-27)
    static let chip: CGFloat = buttonSmall

    /// 헤더 높이 (§6.9) — 두 플랫폼 같은 값
    static let header: CGFloat = 56
    /// 헤더 아이콘 (§6.9) — Android 24 / iOS 26
    static let headerIcon: CGFloat = 26
}

/// DESIGN.md §7 모션 — 이징은 `cubic-bezier(0.2, 0, 0, 1)` (감속 위주).
///
/// 화면 전환(`slow`)은 **안드로이드 `pushSpec` 과 같은 값**이다 (320ms).
enum MyFisMotion {
    /// 눌림, 토글, 체크
    static let fast = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.12 * scale)
    /// 카드 확장, 페이드
    static let base = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.20 * scale)
    /// 바텀시트, 화면 전환
    static let slow = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.32 * scale)

    /// 토스트가 **머무는 시간** (§6.35) — 들어오고 나가는 `base` 와 별개다.
    /// 한 줄을 읽고도 남을 만큼이면 된다. 길면 화면을 가리고, 짧으면 못 읽는다
    static let toastHold: Double = 2.0 * scale

    /// 전환을 늦춰 **중간 프레임**을 본다 — `SIMCTL_CHILD_MYFIS_MOTION=15` (디버그 빌드 전용).
    ///
    /// ⚠️ `MYFIS_SLOWMO` 로는 안 된다 (2026-09-04 확인) — 그건 `window.layer.speed` 라
    /// **창 전환(CoreAnimation)만** 늦춘다. SwiftUI 의 `withAnimation` 값 애니메이션은
    /// 제 타이머로 돌아서 영향을 안 받는다
    private static var scale: Double {
        #if DEBUG
        ProcessInfo.processInfo.environment["MYFIS_MOTION"].flatMap(Double.init) ?? 1
        #else
        1
        #endif
    }
}
