package com.myfis.app.ui.screens

import androidx.annotation.DrawableRes
import com.myfis.app.R

/**
 * 알림 한 건. SPEC.md §5 H-02.
 *
 * TODO(서버): 알림 API 가 아직 없다. 화면을 먼저 세우려고 자리값을 둔다.
 * 붙을 자리는 목록 조회 하나뿐이고, 그때 [notificationPlaceholder] 만 지우면 된다.
 */
data class MyFisNotification(
    val id: Int,
    val kind: Kind,
    val title: String,
    val body: String,
    /** TODO(서버): 서버가 주는 시각으로 상대 시간을 계산한다. 지금은 문자열. */
    val time: String,
    val isUnread: Boolean,
) {
    /** 알림 종류. SPEC.md §5 H-02 "알림 종류" 표와 1:1 이다. */
    enum class Kind(@DrawableRes val icon: Int, val destination: String) {
        ROUTINE(R.drawable.ic_tab_weight, "W-01"),
        MEMBERSHIP(R.drawable.ic_header_membership, "M-06"),
        CARDIO(R.drawable.ic_tab_cardio, "C-04"),
        COUPON(R.drawable.ic_tab_store, "S-04"),
        GROUP(R.drawable.ic_tab_group, "G-02"),
    }
}

val notificationPlaceholder = listOf(
    MyFisNotification(
        1, MyFisNotification.Kind.ROUTINE,
        "이번 주 루틴이 도착했어요",
        "월·수·금 3일 루틴 — 하체부터 시작합니다",
        "10분 전", isUnread = true,
    ),
    MyFisNotification(
        2, MyFisNotification.Kind.CARDIO,
        "유산소가 자동 종료됐어요",
        "러닝머신 3번 · 5분간 거리가 늘지 않아 세션을 닫았습니다",
        "1시간 전", isUnread = true,
    ),
    MyFisNotification(
        3, MyFisNotification.Kind.COUPON,
        "교환권이 곧 만료돼요",
        "이온음료 교환권 · 내일 23:59까지",
        "어제", isUnread = false,
    ),
    MyFisNotification(
        4, MyFisNotification.Kind.GROUP,
        "새벽 러닝크루에 새 글이 올라왔어요",
        "내일 비 오면 실내 트랙으로 갈게요",
        "어제", isUnread = false,
    ),
    MyFisNotification(
        5, MyFisNotification.Kind.MEMBERSHIP,
        "회원권이 7일 남았어요",
        "6개월 회원권 · 9월 3일 만료",
        "3일 전", isUnread = false,
    ),
)
