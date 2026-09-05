package com.myfis.app.ui.theme

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.TweenSpec
import androidx.compose.animation.core.FiniteAnimationSpec
import androidx.compose.animation.core.snap
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue

/**
 * DESIGN.md §7 모션. iOS `MyFisMotion` 과 값이 같아야 한다 — 한쪽만 고치지 않는다.
 *
 * 감속 위주 이징 하나만 쓴다. 시간으로 성격을 구분한다.
 */
object MyFisMotion {
    val easing = CubicBezierEasing(0.2f, 0f, 0f, 1f)

    /** 눌림, 토글, 체크 */
    fun <T> fast(): TweenSpec<T> = tween(durationMillis = 120, easing = easing)

    /** 카드 확장, 페이드, 선택 이동 */
    fun <T> base(): TweenSpec<T> = tween(durationMillis = 200, easing = easing)

    /** 바텀시트, 화면 전환 */
    fun <T> slow(): TweenSpec<T> = tween(durationMillis = 320, easing = easing)
}

/**
 * ⚠️⚠️ **잰 값으로 움직이는 것은 처음 한 번을 안 움직인다** 🟢 (2026-09-05 버그, 사용자 지적).
 *
 * 밑줄·알약처럼 **레이아웃을 재서** 자리를 잡는 것은 첫 프레임에 잰 값이 없어 `0` 이다.
 * 그대로 `animateDpAsState` 를 걸면 화면에 들어올 때 **선이 왼쪽에서 오른쪽으로 자란다.**
 *
 * iOS 는 `.animation(_, value: selected)` 라 **고른 것이 바뀔 때만** 움직여서 이 문제가 없다.
 * 안드로이드에는 그 문법이 없으므로, **처음 잰 값에는 `snap`** 을 주어 같은 결과를 만든다.
 *
 * ```
 * val spec = rememberMeasuredSpec(bar != null)
 * val barX by animateDpAsState(x, spec)
 * ```
 */
@Composable
fun <T> rememberMeasuredSpec(measured: Boolean): FiniteAnimationSpec<T> {
    var ready by remember { mutableStateOf(false) }
    LaunchedEffect(measured) { if (measured) ready = true }
    return if (ready) MyFisMotion.fast() else snap()
}
