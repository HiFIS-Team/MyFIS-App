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
}
