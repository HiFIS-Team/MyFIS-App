import SwiftUI

/// DESIGN.md §3 컬러 토큰.
///
/// 이 파일 밖에서 `Color(hex:)` 를 직접 쓰지 않는다.
/// 새 색이 필요하면 DESIGN.md 에 먼저 추가하고 여기에 옮긴다.
///
/// 다크 전용이라 Asset Catalog 대신 상수로 둔다 (라이트/다크 변형이 필요 없다).
enum MyFisColor {
    // 배경 (surface) — **순검정이 아니다** (2026-08-26). 카카오뱅크처럼 **중립 회색** 바탕에 카드를 얹는다
    static let bgBase = Color(hex: 0x1B1B1D)
    static let surface1 = Color(hex: 0x232327)
    static let surface2 = Color(hex: 0x2B2C31)
    static let surface3 = Color(hex: 0x35363C)

    // 경계
    static let borderSubtle = Color(hex: 0x41424B)
    static let borderStrong = Color(hex: 0x6B7383)

    // 텍스트 — textTertiary 가 AA 하한선(surface.3 위 4.69:1). 이보다 어둡게 쓰지 않는다.
    static let textPrimary = Color(hex: 0xFFFFFF)
    static let textSecondary = Color(hex: 0xA3A9B5)
    static let textTertiary = Color(hex: 0x9BA2AF)

    // ── 라이트 면 (혜택·활동 화면) 🟢 (2026-08-28 사용자 지정) ──
    //
    // §9 이탈 #1 은 "다크 고정" 이지만, **혜택(P-01)과 그 활동 화면들은 흰 바탕**으로 간다.
    // 카카오뱅크·토스의 혜택 화면이 밝은 것과 같은 판단이다.
    //
    // ⚠️ **라임은 흰 면 위에서 `칠`로만 쓴다.** 글자·테두리로 쓰면 안 된다 —
    //    흰 배경 대비가 **1.27:1** 이라 아예 안 보인다 (실측 2026-08-28).
    //    라임 판 위 검정 글자는 16.6:1 로 잘 읽힌다 — 카카오뱅크가 노랑을 쓰는 방식과 같다
    static let lightBgBase = Color(hex: 0xFFFFFF)
    static let lightSurface1 = Color(hex: 0xF5F6F8)
    static let lightSurface2 = Color(hex: 0xEDEFF2)
    static let lightSurface3 = Color(hex: 0xE1E4E9)
    static let lightBorderSubtle = Color(hex: 0xE5E7EB)
    static let lightBorderStrong = Color(hex: 0xC3C8D0)

    /// 17.2:1
    static let lightTextPrimary = Color(hex: 0x1B1B1D)
    /// 6.1:1
    static let lightTextSecondary = Color(hex: 0x5A6273)
    /// 4.8:1 — **AA 하한선이므로 이보다 밝게 쓰지 않는다** (다크의 `text.tertiary` 와 같은 구실)
    static let lightTextTertiary = Color(hex: 0x6B7280)

    // ── 밝은 면의 갈래 액센트 🟢 (2026-08-28 사용자 지정) ──
    //
    // 활동 화면이 흰 바탕이 되면서 **라임이 강조로 약해졌다** (흰 위 1.27:1).
    // 그래서 밝은 면에서는 **그 활동의 갈래 색을 진하게** 써서 강조한다 — 활동마다 색이 다르다.
    // 갈래 색 원본(`categoryCyan` #22D3EE)은 흰 위에서 1.81:1 이라 그대로는 못 쓴다.
    //
    // ⚠️ 이 색들은 **밝은 면 전용**이다. 다크 화면의 갈래 색은 §3.1 그대로 둔다
    // 전부 **흰 배경 위 4.5:1 이상**이다 — 테두리로도, 칠 위 흰 글자로도 쓸 수 있다.
    // 갈래 색의 색상(H)·채도(S)는 그대로 두고 밝기(L)만 낮춰 뽑았다
    /// 물 마시기(P-05). 4.87:1
    static let lightAccentCyan = Color(hex: 0x0277B5)
    static let lightAccentGold = Color(hex: 0x986E03)
    static let lightAccentLime = Color(hex: 0x647F06)
    static let lightAccentBlue = Color(hex: 0x216BFF)
    static let lightAccentViolet = Color(hex: 0x8058F8)
    static let lightAccentOrange = Color(hex: 0xBE5804)
    static let lightAccentTeal = Color(hex: 0x1B8578)
    static let lightAccentFuchsia = Color(hex: 0xC90AE6)
    static let lightAccentIndigo = Color(hex: 0x5867F6)
    static let lightAccentGreen = Color(hex: 0x198841)
    static let lightAccentPink = Color(hex: 0xE2127E)
    static let lightAccentCoral = Color(hex: 0xE02F00)
    static let lightAccentGray = Color(hex: 0x6D7688)

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
    static let categoryPink = Color(hex: 0xF472B6)
    /// 보라와 분홍 딱 사이 (292°) — 열두 색이 비워 둔 제일 넓은 구간이다 🟢 (2026-08-26)
    static let categoryFuchsia = Color(hex: 0xE879F9)
    static let categoryCyan = Color(hex: 0x22D3EE)
    static let categoryOrange = Color(hex: 0xFB923C)
    static let categoryTeal = Color(hex: 0x2DD4BF)
    static let categoryIndigo = Color(hex: 0x818CF8)
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
