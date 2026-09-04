package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import kotlin.math.roundToInt

/**
 * DESIGN.md §6.31 **단계 슬라이더** — 몇 칸 중 몇 번째인지 고른다.
 *
 * 값을 정확히 재는 자가 아니라 **`가까운` ↔ `먼` 사이 어디쯤**을 고르는 손잡이다.
 * 그래서 연속값이 아니라 **칸**이다 — 칸 사이 눈금이 몇 단계인지 말해 준다.
 *
 * **손잡이는 흰색 하나다.** 라임은 화면당 두 곳이 상한이라(§3.2) 여기까지 칠하면
 * 진짜 액션(`다음`)이 묻힌다 — 다크에서 흰 원은 그것만으로 충분히 앞선다.
 */
@Composable
fun MyFisSlider(
    step: Int,
    onStep: (Int) -> Unit,
    modifier: Modifier = Modifier,
    /** 칸 수. 눈금은 `steps - 1` 개 그린다 */
    steps: Int = 4,
) {
    val density = LocalDensity.current
    var x by remember { mutableFloatStateOf(0f) }

    BoxWithConstraints(modifier.fillMaxWidth().height(Knob)) {
        val span = maxWidth - Knob
        val ratio = if (steps <= 1) 0f else step.toFloat() / (steps - 1)
        val spanPx = with(density) { span.toPx() }
        val knobPx = with(density) { Knob.toPx() }

        fun pick(raw: Float) {
            val clamped = (raw - knobPx / 2).coerceIn(0f, spanPx)
            val next = (clamped / spanPx.coerceAtLeast(1f) * (steps - 1)).roundToInt()
            // 칸을 넘을 때만 바꾼다 — 끄는 내내 상태를 갈면 진동이 계속 울린다
            if (next != step) onStep(next)
        }

        Box(
            Modifier
                .fillMaxWidth()
                .height(Knob)
                .pointerInput(steps, step) {
                    detectTapGestures { pick(it.x) }
                }
                .pointerInput(steps, step) {
                    detectHorizontalDragGestures { change, _ ->
                        x = change.position.x
                        pick(x)
                    }
                },
        ) {
            Box(
                Modifier
                    .align(Alignment.CenterStart)
                    .fillMaxWidth()
                    .height(Track)
                    .background(MyFisColor.Surface2, MyFisRadius.full),
            )
            // 칸 사이 눈금 — 몇 단계인지 손잡이를 안 움직여도 보인다
            for (index in 1 until (steps - 1).coerceAtLeast(1)) {
                Box(
                    Modifier
                        .align(Alignment.CenterStart)
                        .offset(x = Knob / 2 + span * index / (steps - 1))
                        .width(1.dp)
                        .height(10.dp)
                        .background(MyFisColor.Surface3),
                )
            }
            Box(
                Modifier
                    .align(Alignment.CenterStart)
                    .offset(x = span * ratio)
                    .size(Knob)
                    .background(MyFisColor.TextPrimary, MyFisRadius.full),
            )
        }
    }
}

private val Knob = 34.dp
private val Track = 4.dp
