package com.myfis.app.ui.theme

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.InteractionSource
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback

/**
 * DESIGN.md §6.7 누름 피드백 — 하단 탭에서 시작해 헤더·주간 캘린더가 같이 쓴다.
 *
 * 리플(`indication`)은 쓰지 않는다. 스케일 + 진동으로 충분하고,
 * 리플은 라운드 바 밖으로 번진다.
 */

/**
 * 누르면 살짝 작아졌다 되돌아온다.
 *
 * 되돌아올 때 스프링이 살짝 튀게(`dampingRatio` 를 낮게) 둬야 "눌렀다"는 느낌이 산다.
 */
@Composable
fun InteractionSource.pressScale(): State<Float> {
    val pressed by collectIsPressedAsState()
    return animateFloatAsState(
        targetValue = if (pressed) 0.86f else 1f,
        animationSpec = spring(dampingRatio = 0.45f, stiffness = 900f),
        label = "pressScale",
    )
}

/** 가벼운 진동을 붙인다. 결과가 눈에 보이는 선택은 약한 tick 이면 충분하다. */
@Composable
fun Modifier.tapWithHaptics(
    interaction: MutableInteractionSource,
    onClick: () -> Unit,
): Modifier {
    val haptics = LocalHapticFeedback.current
    return this.clickable(
        interactionSource = interaction,
        indication = null,
        onClick = {
            haptics.performHapticFeedback(HapticFeedbackType.SegmentTick)
            onClick()
        },
    )
}
