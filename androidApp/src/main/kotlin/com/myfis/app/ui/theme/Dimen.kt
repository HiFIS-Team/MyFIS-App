package com.myfis.app.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.unit.dp

/** DESIGN.md §5.1 간격 — 4pt 베이스 */
object MyFisSpacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 12.dp
    val lg = 16.dp
    val xl = 20.dp
    val xxl = 24.dp
    val xxxl = 32.dp
    val huge = 40.dp
    val giant = 56.dp

    /** 화면 좌우 여백 */
    val screenHorizontal = 20.dp

    /** 카드 내부 패딩 */
    val cardPadding = 16.dp

    /** 카드 사이 간격 */
    val cardGap = 12.dp

    /** 섹션 사이 간격 */
    val sectionGap = 32.dp
}

/** DESIGN.md §5.2 라운딩 */
object MyFisRadius {
    val sm = RoundedCornerShape(8.dp)
    val md = RoundedCornerShape(12.dp)
    val lg = RoundedCornerShape(20.dp)

    /** 아이콘 판 (§6.23 혜택 행) — `56` 판에 맞춘 값이다. 다른 크기에 그대로 쓰지 않는다 */
    val tile = RoundedCornerShape(18.dp)
    val full = RoundedCornerShape(percent = 50)
}

/** DESIGN.md §5.3 터치 타겟 / §6.1 버튼 높이 */
object MyFisSize {
    val minTouchTarget = 48.dp
    val buttonPrimary = 52.dp
    val buttonSecondary = 44.dp

    /** 카드 안 보조 버튼 (§6.1) */
    val buttonSmall = 36.dp
    val inputHeight = 52.dp
    val listRowMin = 56.dp
    val progressHeight = 8.dp
}
