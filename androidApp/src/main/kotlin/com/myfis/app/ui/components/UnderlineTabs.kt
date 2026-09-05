package com.myfis.app.ui.components

import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.rememberMeasuredSpec
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * DESIGN.md §6.29 **밑줄 갈래 줄** — 글자 + 흐르는 밑줄.
 *
 * 알약이 아니라 **글자 + 밑줄**이다. 목록 위에서 알약은 시각적으로 너무 무겁고,
 * 여기서 고른 것은 "지금 보고 있는 목록"이라 **제목처럼 읽혀야** 한다.
 *
 * **고른 것은 색이 아니라 밑줄로 알린다** — 라임은 버튼과 진행바의 몫이다 (§3.2 액센트 2곳).
 *
 * 밑줄을 그리려면 고른 글자가 **어디서 시작해 얼마나 넓은지**를 알아야 한다.
 * 스크롤하면 위치가 바뀌므로 화면 기준으로 재고 컨테이너 기준으로 환산한다.
 *
 * ⚠️ 이 꼴을 스토어(§6.12)와 유산소(§6.27)가 **각자 그리고 있다.** 모임(§6.29)이 세 번째라
 * 여기 한 벌로 모았다 — 두 화면의 이관은 아직이다 (2026-09-04, `ui-design` 금지 6번).
 */
@Composable
fun <T> MyFisUnderlineTabs(
    items: List<T>,
    selected: T,
    onSelect: (T) -> Unit,
    title: (T) -> String,
    modifier: Modifier = Modifier,
) {
    val density = LocalDensity.current
    var containerX by remember { mutableFloatStateOf(0f) }
    val bars = remember { mutableStateMapOf<Int, Pair<Float, Float>>() }
    val index = items.indexOf(selected).coerceAtLeast(0)
    val bar = bars[index]
    // 고르는 동작이라 `fast`(120ms) 다. `base`(200ms) 는 감속 커브 때문에 끝이 끌린다.
    // **처음 잰 값에는 안 움직인다** — 안 그러면 들어올 때 선이 왼쪽에서 오른쪽으로 자란다
    val spec = rememberMeasuredSpec<Dp>(bar != null)
    val barX by animateDpAsState(
        with(density) { (bar?.first ?: 0f).toDp() }, spec, label = "barX",
    )
    val barWidth by animateDpAsState(
        with(density) { (bar?.second ?: 0f).toDp() }, spec, label = "barWidth",
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            .onGloballyPositioned { containerX = it.positionInRoot().x },
    ) {
        Row(
            Modifier
                .horizontalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        ) {
            items.forEachIndexed { i, item ->
                val isSelected = item == selected
                val interaction = remember { MutableInteractionSource() }
                Text(
                    title(item),
                    style = MyFisTheme.type.titleSm,
                    color = if (isSelected) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier
                        .tapWithHaptics(interaction) { onSelect(item) }
                        .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.md)
                        .onGloballyPositioned { coords ->
                            bars[i] = (coords.positionInRoot().x - containerX) to coords.size.width.toFloat()
                        },
                )
            }
        }

        // 바닥 줄이 칸들을 하나로 묶는다 — 없으면 밑줄이 허공에서 움직인다
        Box(
            Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
        Box(
            Modifier
                .align(Alignment.BottomStart)
                .offset(x = barX)
                .width(barWidth)
                .height(2.dp)
                .background(MyFisColor.TextPrimary),
        )
    }
}
