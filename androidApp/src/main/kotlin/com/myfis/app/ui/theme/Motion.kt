package com.myfis.app.ui.theme

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.TweenSpec
import androidx.compose.animation.core.tween

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
