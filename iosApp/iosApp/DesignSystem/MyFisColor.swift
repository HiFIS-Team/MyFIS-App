import SwiftUI

/// DESIGN.md §3 컬러 토큰.
///
/// 이 파일 밖에서 `Color(hex:)` 를 직접 쓰지 않는다.
/// 새 색이 필요하면 DESIGN.md 에 먼저 추가하고 여기에 옮긴다.
///
/// 다크 전용이라 Asset Catalog 대신 상수로 둔다 (라이트/다크 변형이 필요 없다).
enum MyFisColor {
    // 배경 (surface)
    static let bgBase = Color(hex: 0x000000)
    static let surface1 = Color(hex: 0x0E0F12)
    static let surface2 = Color(hex: 0x16181D)
    static let surface3 = Color(hex: 0x1F2229)

    // 경계
    static let borderSubtle = Color(hex: 0x2C3038)
    static let borderStrong = Color(hex: 0x6B7383)

    // 텍스트 — textTertiary 가 AA 하한선(4.5:1). 이보다 어둡게 쓰지 않는다.
    static let textPrimary = Color(hex: 0xFFFFFF)
    static let textSecondary = Color(hex: 0xA3A9B5)
    static let textTertiary = Color(hex: 0x828997)

    // 액센트 — 한 화면에 2곳 이하
    static let accent = Color(hex: 0xC9F531)
    static let accentPressed = Color(hex: 0xA8CE24)
    /// 액센트 위 텍스트는 항상 검정. 흰 글자는 1.3:1 이라 안 읽힌다.
    static let onAccent = Color(hex: 0x000000)

    // 달력 주말 — 한국 달력 관행. 시맨틱(상태)과 값은 같아도 쓰임이 달라 따로 둔다.
    static let weekendSaturday = Color(hex: 0x7DA8FF)
    static let weekendSunday = Color(hex: 0xFF6B6B)

    /// 찜(하트) 전용. 시맨틱도 카테고리도 아니고 **이 한 가지 기능의 색**이다.
    static let like = Color(hex: 0xFF4D6D)
    /// 별점 별 — 시맨틱 `warning` 과 값은 같지만 상태가 아니라 **평점 표시**다
    static let rating = Color(hex: 0xFBBF24)
    /// `도움 됐어요` 켜진 상태 — `info` 와 값은 같지만 상태가 아니라 표시다
    static let helpful = Color(hex: 0x7DA8FF)

    // 카테고리 — **목록에서 종류를 구분할 때만** 쓴다 (§6.19).
    // 액션 색이 아니라 분류 표시라 액센트 예산(2곳)에 넣지 않는다.
    static let categoryLime = Color(hex: 0xC9F531)
    static let categoryBlue = Color(hex: 0x7DA8FF)
    static let categoryGold = Color(hex: 0xFBBF24)
    static let categoryCoral = Color(hex: 0xFF8A6B)
    static let categoryGreen = Color(hex: 0x4ADE80)
    static let categoryViolet = Color(hex: 0xA78BFA)
    static let categoryGray = Color(hex: 0xA3A9B5)

    // 시맨틱 — 상태 표시 전용. 브랜드 색으로 쓰지 않는다.
    static let success = Color(hex: 0x4ADE80)
    static let warning = Color(hex: 0xFBBF24)
    static let danger = Color(hex: 0xFF6B6B)
    static let info = Color(hex: 0x7DA8FF)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
