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
    static let full: CGFloat = 999
}

/// DESIGN.md §5.3 터치 타겟 / §6.1 버튼 높이
enum MyFisSize {
    static let minTouchTarget: CGFloat = 44
    static let buttonPrimary: CGFloat = 52
    static let buttonSecondary: CGFloat = 44
    static let inputHeight: CGFloat = 52
    static let listRowMin: CGFloat = 56
    static let progressHeight: CGFloat = 8
    /// 카드 안 보조 버튼 (§6.1)
    static let buttonSmall: CGFloat = 36

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
    static let fast = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.12)
    /// 카드 확장, 페이드
    static let base = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.20)
    /// 바텀시트, 화면 전환
    static let slow = Animation.timingCurve(0.2, 0, 0, 1, duration: 0.32)
}
