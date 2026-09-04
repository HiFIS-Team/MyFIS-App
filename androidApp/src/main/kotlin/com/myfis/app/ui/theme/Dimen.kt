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

    /** 그 `18 / 56`. 판 크기가 다르면 이 비율로 다시 뽑는다 (§6.26 · 2026-09-04) */
    const val tileRatio = 18f / 56f

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

    /**
     * 알약 칩·뱃지 높이 (§5.2) — 마일리지 칩 · 연속 출석 · 펼쳐보기 · 도움 됐어요.
     *
     * **`buttonSmall` 과 같은 값이다.** 숫자를 새로 만든 게 아니라 이름을 준 것 —
     * 칩과 Small 버튼은 나란히 서는 일이 있어 높이가 같아야 한다.
     *
     * ⚠️ 전에는 세로 여백(`6`·`7`)으로 높이를 만들었는데 그 값이 §5.1 스케일 밖이었다.
     * 높이를 못 박으면 글꼴이나 아이콘이 바뀌어도 칩이 안 흔들린다 (2026-08-27)
     */
    val chip = buttonSmall
    val inputHeight = 52.dp

    /** 큰 찾기 줄 (M-08) — 입력 필드보다 크다. **화면에서 제일 먼저 눈에 들어와야** 한다 */
    val searchBar = 64.dp
    val listRowMin = 56.dp
    val progressHeight = 8.dp

    /** 헤더 높이 (§6.9) — iOS `MyFisSize.header` 와 같은 값. 화면마다 `56.dp` 를 박아 쓰고 있었다 */
    val header = 56.dp
}
