package com.myfis.app.ui.shell

import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.tween
import androidx.compose.ui.unit.IntOffset
import androidx.lifecycle.Lifecycle
import androidx.navigation.NavController

/** 화면 경로. */
object Route {
    /** 탭 셸 (하단 바 + 헤더). 잎 화면은 이 위를 통째로 덮는다. */
    const val SHELL = "shell"

    /** H-02 알림함 */
    const val NOTIFICATIONS = "notifications"

    /** S-08 스토어 마이 — 마이 탭(Y-01)과 다른 화면이다 */
    const val STORE_MY = "store_my"
    const val STORE_CART = "store_cart"

    /** S-07 상품 검색 — 스토어 헤더의 돋보기로 들어온다 */
    const val STORE_SEARCH = "store_search"

    /** G-01 모임 검색 — 모임 헤더의 돋보기로 들어온다 */
    const val GROUP_SEARCH = "group_search"

    /** P-08 체중 기록 */
    const val WEIGHT_LOG = "weight_log"

    /** G-03 모임 개설 — 모임 탭(G-01)의 `＋ 모임 만들기` 로 들어온다 */
    const val GROUP_CREATE = "group_create"

    /** G-03 활동 지역 설정 — 개설 화면의 `검색` 칩으로 들어온다 */
    const val GROUP_REGION = "group_region"

    /** G-03 모임 개설 **2단계** — 소개 쓰기 */
    const val GROUP_INTRO = "group_intro"

    /** 적립 활동 랜딩 (DESIGN §6.25) */
    const val ACTIVITY_INTRO = "activity_intro"

    /** S-02 상품 상세 */
    const val STORE_ITEM = "store_item"

    /** M-01 지점 선택 — 홈 헤더의 핀으로 들어온다 */
    const val BRANCH = "branch"

    /** P-05 물 마시기 — 활동 랜딩을 거치지 않고 바로 연다 */
    const val WATER = "water"

    /** P-05 물 마시기 — 미션 시각 고르기 */
    const val WATER_TIME = "water_time"
}

/**
 * 화면 전환 스펙 — DESIGN.md §7 `slow`(320ms) / `cubic-bezier(0.2, 0, 0, 1)`.
 *
 * 시스템 "애니메이션 배율"이 0이면 Compose 가 알아서 즉시 전환한다 (MotionDurationScale).
 */
val pushSpec = tween<IntOffset>(
    durationMillis = 320,
    easing = CubicBezierEasing(0.2f, 0f, 0f, 1f),
)

/**
 * 연타로 같은 화면이 두 번 쌓이는 걸 막는다.
 *
 * 전환 중에는 현재 항목이 `RESUMED` 가 아니다 — 그때 들어온 탭은 버린다.
 */
fun NavController.navigateOnce(route: String) {
    if (currentBackStackEntry?.lifecycle?.currentState == Lifecycle.State.RESUMED) {
        navigate(route)
    }
}
