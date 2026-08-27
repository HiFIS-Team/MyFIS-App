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

    /** 바닥 시트 — **위 모서리만** 둥글다. 네 모서리를 다 굴리면 바닥에서 뜬 카드가 된다 */
    val sheet = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
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

    /** 큰 찾기 줄 (M-08) — 입력 필드보다 크다. **화면에서 제일 먼저 눈에 들어와야** 한다 */
    val searchBar = 64.dp
    val listRowMin = 56.dp

    /** 헤더 높이 (§6.9) — 셸 헤더와 잎 헤더가 같은 값이다 */
    val header = 56.dp
    val progressHeight = 8.dp
}
