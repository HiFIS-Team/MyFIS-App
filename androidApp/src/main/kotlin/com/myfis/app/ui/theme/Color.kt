package com.myfis.app.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * DESIGN.md §3 컬러 토큰.
 *
 * 이 파일 밖에서 Color(0x...) 를 직접 쓰지 않는다.
 * 새 색이 필요하면 DESIGN.md 에 먼저 추가하고 여기에 옮긴다.
 */
object MyFisColor {
    // 배경 (surface) — **순검정이 아니다** (2026-08-26). 카카오뱅크처럼 **중립 회색** 바탕에 카드를 얹는다
    val BgBase = Color(0xFF1B1B1D)
    val Surface1 = Color(0xFF232327)
    val Surface2 = Color(0xFF2B2C31)
    val Surface3 = Color(0xFF35363C)

    // 경계
    val BorderSubtle = Color(0xFF41424B)
    val BorderStrong = Color(0xFF6B7383)

    // 텍스트 — TextTertiary 가 AA 하한선(Surface.3 위 4.69:1). 이보다 어둡게 쓰지 않는다.
    val TextPrimary = Color(0xFFFFFFFF)
    val TextSecondary = Color(0xFFA3A9B5)
    val TextTertiary = Color(0xFF9BA2AF)

    // ── 라이트 면 (혜택·활동 화면) 🟢 (2026-08-28 사용자 지정) ──
    //
    // §9 이탈 #1 은 "다크 고정" 이지만, **혜택(P-01)과 그 활동 화면들은 흰 바탕**으로 간다.
    // 카카오뱅크·토스의 혜택 화면이 밝은 것과 같은 판단이다.
    //
    // ⚠️ **라임은 흰 면 위에서 `칠`로만 쓴다.** 글자·테두리로 쓰면 안 된다 —
    //    흰 배경 대비가 **1.27:1** 이라 아예 안 보인다 (실측 2026-08-28).
    //    라임 판 위 검정 글자는 16.6:1 로 잘 읽힌다 — 카카오뱅크가 노랑을 쓰는 방식과 같다
    val LightBgBase = Color(0xFFFFFFFF)
    val LightSurface1 = Color(0xFFF5F6F8)
    val LightSurface2 = Color(0xFFEDEFF2)
    val LightSurface3 = Color(0xFFE1E4E9)
    val LightBorderSubtle = Color(0xFFE5E7EB)
    val LightBorderStrong = Color(0xFFC3C8D0)

    /** 17.2:1 */
    val LightTextPrimary = Color(0xFF1B1B1D)
    /** 6.1:1 */
    val LightTextSecondary = Color(0xFF5A6273)
    /** 4.8:1 — **AA 하한선이므로 이보다 밝게 쓰지 않는다** (다크의 `text.tertiary` 와 같은 구실) */
    val LightTextTertiary = Color(0xFF6B7280)

    // ── 밝은 면의 갈래 액센트 🟢 (2026-08-28 사용자 지정) ──
    //
    // 활동 화면이 흰 바탕이 되면서 **라임이 강조로 약해졌다** (흰 위 1.27:1).
    // 그래서 밝은 면에서는 **그 활동의 갈래 색을 진하게** 써서 강조한다 — 활동마다 색이 다르다.
    // 갈래 색 원본(`CategoryCyan` #22D3EE)은 흰 위에서 1.81:1 이라 그대로는 못 쓴다.
    //
    // ⚠️ 이 색들은 **밝은 면 전용**이다. 다크 화면의 갈래 색은 §3.1 그대로 둔다
    // 전부 **흰 배경 위 4.5:1 이상**이다 — 테두리로도, 칠 위 흰 글자로도 쓸 수 있다.
    // 갈래 색의 색상(H)·채도(S)는 그대로 두고 밝기(L)만 낮춰 뽑았다
    /** 물 마시기(P-05). 4.87:1 */
    val LightAccentCyan = Color(0xFF0277B5)
    val LightAccentGold = Color(0xFF986E03)
    val LightAccentLime = Color(0xFF647F06)
    val LightAccentBlue = Color(0xFF216BFF)
    val LightAccentViolet = Color(0xFF8058F8)
    val LightAccentOrange = Color(0xFFBE5804)
    val LightAccentTeal = Color(0xFF1B8578)
    val LightAccentFuchsia = Color(0xFFC90AE6)
    val LightAccentIndigo = Color(0xFF5867F6)
    val LightAccentGreen = Color(0xFF198841)
    val LightAccentPink = Color(0xFFE2127E)
    val LightAccentCoral = Color(0xFFE02F00)
    val LightAccentGray = Color(0xFF6D7688)

    // 액센트 — 한 화면에 2곳 이하
    val Accent = Color(0xFFC9F531)
    val AccentPressed = Color(0xFFA8CE24)
    val OnAccent = Color(0xFF000000)

    // 달력 주말 — 한국 달력 관행. 시맨틱(상태)과 값은 같아도 쓰임이 달라 따로 둔다.
    val WeekendSaturday = Color(0xFF7DA8FF)
    val WeekendSunday = Color(0xFFFF6B6B)

    // 찜(하트) 전용. 시맨틱도 카테고리도 아니고 **이 한 가지 기능의 색**이다.
    val Like = Color(0xFFFF4D6D)

    /** 별점 별. 시맨틱 `warning` 과 값은 같지만 상태가 아니라 **평점 표시**다 */
    val Rating = Color(0xFFFBBF24)

    /** `도움 됐어요` 켜진 상태. `Info` 와 값은 같지만 **상태가 아니라 표시**다 */
    val Helpful = Color(0xFF7DA8FF)

    // 카테고리 — **목록에서 종류를 구분할 때만** 쓴다 (§6.19).
    // 액션 색이 아니라 분류 표시라 액센트 예산(2곳)에 넣지 않는다.
    val CategoryLime = Color(0xFFC9F531)
    val CategoryBlue = Color(0xFF7DA8FF)
    val CategoryGold = Color(0xFFFBBF24)
    val CategoryCoral = Color(0xFFFF8A6B)
    val CategoryGreen = Color(0xFF4ADE80)
    val CategoryViolet = Color(0xFFA78BFA)
    val CategoryPink = Color(0xFFF472B6)

    /** 보라와 분홍 딱 사이 (292°) — 열두 색이 비워 둔 제일 넓은 구간이다 🟢 (2026-08-26) */
    val CategoryFuchsia = Color(0xFFE879F9)
    val CategoryCyan = Color(0xFF22D3EE)
    val CategoryOrange = Color(0xFFFB923C)
    val CategoryTeal = Color(0xFF2DD4BF)
    val CategoryIndigo = Color(0xFF818CF8)
    val CategoryGray = Color(0xFFA3A9B5)

    // 시맨틱 — 상태 표시 전용. 브랜드 색으로 쓰지 않는다.
    val Success = Color(0xFF4ADE80)
    val Warning = Color(0xFFFBBF24)
    val Danger = Color(0xFFFF6B6B)
    val Info = Color(0xFF7DA8FF)
}
