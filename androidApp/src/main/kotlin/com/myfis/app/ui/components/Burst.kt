package com.myfis.app.ui.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisMotion
import kotlinx.coroutines.launch

/**
 * 켜질 때 **한 번 튀고 고리가 퍼지는** 반응 (DESIGN.md §6.21).
 *
 * 찜 하트와 리뷰의 `도움 됐어요` 가 같이 쓴다 —
 * 같은 종류의 행동이면 반응도 같아야 한 앱으로 읽힌다.
 *
 * **켤 때만** 터뜨린다. 해제까지 축하하면 과하다.
 */
@Immutable
data class Burst(
    /** 아이콘 배율 */
    val pop: Float,
    /** 0 = 막 터짐, 1 = 끝난 상태(안 보임) */
    val ring: Float,
)

@Composable
fun rememberBurst(active: Boolean): Burst {
    val pop = remember { Animatable(1f) }
    val ring = remember { Animatable(1f) }

    LaunchedEffect(active) {
        if (!active) return@LaunchedEffect
        launch {
            pop.animateTo(1.3f, MyFisMotion.fast())
            pop.animateTo(1f, spring(dampingRatio = 0.42f, stiffness = 340f))
        }
        ring.snapTo(0f)
        ring.animateTo(1f, tween(RingMillis, easing = LinearOutSlowInEasing))
    }

    return Burst(pop = pop.value, ring = ring.value)
}

/** 아이콘 둘레로 한 번 퍼지는 고리. 눌린 게 손끝 말고 **눈으로도** 보여야 한다 */
@Composable
fun BurstRing(progress: Float, color: Color, modifier: Modifier = Modifier) {
    if (progress >= 1f) return

    Canvas(modifier) {
        drawCircle(
            color = color,
            radius = size.minDimension / 2 * (0.45f + progress * 0.75f),
            alpha = 1f - progress,
            style = Stroke(width = (3.5f * (1f - progress) + 0.5f).dp.toPx()),
        )
    }
}

/** 고리가 퍼져 사라지기까지 */
private const val RingMillis = 420
