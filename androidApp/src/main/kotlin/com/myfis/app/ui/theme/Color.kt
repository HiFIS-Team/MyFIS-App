package com.myfis.app.ui.theme

import androidx.compose.ui.graphics.Color

/**
 * DESIGN.md §3 컬러 토큰.
 *
 * 이 파일 밖에서 Color(0x...) 를 직접 쓰지 않는다.
 * 새 색이 필요하면 DESIGN.md 에 먼저 추가하고 여기에 옮긴다.
 */
object MyFisColor {
    // 배경 (surface)
    val BgBase = Color(0xFF000000)
    val Surface1 = Color(0xFF0E0F12)
    val Surface2 = Color(0xFF16181D)
    val Surface3 = Color(0xFF1F2229)

    // 경계
    val BorderSubtle = Color(0xFF2C3038)
    val BorderStrong = Color(0xFF6B7383)

    // 텍스트 — TextTertiary 가 AA 하한선(4.5:1). 이보다 어둡게 쓰지 않는다.
    val TextPrimary = Color(0xFFFFFFFF)
    val TextSecondary = Color(0xFFA3A9B5)
    val TextTertiary = Color(0xFF828997)

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
    val CategoryGray = Color(0xFFA3A9B5)

    // 시맨틱 — 상태 표시 전용. 브랜드 색으로 쓰지 않는다.
    val Success = Color(0xFF4ADE80)
    val Warning = Color(0xFFFBBF24)
    val Danger = Color(0xFFFF6B6B)
    val Info = Color(0xFF7DA8FF)
}
