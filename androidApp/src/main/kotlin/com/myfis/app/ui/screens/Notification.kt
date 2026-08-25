package com.myfis.app.ui.screens

import androidx.annotation.DrawableRes
import androidx.compose.ui.graphics.Color
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor

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
    /** 같은 종류가 여러 건 묶였을 때만. 한 건이면 `null` */
    val count: Int? = null,
) {
    /** 알림 종류. SPEC.md §5 H-02 "알림 종류" 표와 1:1 이다. */
    enum class Kind(
        @DrawableRes val icon: Int,
        /** 목록에서 종류를 구분하는 색 (DESIGN.md §6.19) */
        val color: Color,
        val destination: String,
    ) {
        ROUTINE(R.drawable.ic_tab_weight, MyFisColor.CategoryLime, "W-01"),
        MEMBERSHIP(R.drawable.ic_header_membership, MyFisColor.CategoryViolet, "M-06"),
        CARDIO(R.drawable.ic_tab_cardio, MyFisColor.CategoryBlue, "C-04"),
        COUPON(R.drawable.ic_tab_store, MyFisColor.CategoryCoral, "S-04"),
        MILEAGE(R.drawable.ic_mileage_fill, MyFisColor.CategoryGold, "P-01"),
        NOTICE(R.drawable.ic_header_notification, MyFisColor.CategoryGray, "H-04"),
        GROUP(R.drawable.ic_tab_group, MyFisColor.CategoryGreen, "G-02"),
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
        3, MyFisNotification.Kind.MILEAGE,
        "마일리지 50 P 적립",
        "출석 체크 · 오늘까지 3일 연속",
        "3시간 전", isUnread = true,
    ),
    MyFisNotification(
        4, MyFisNotification.Kind.COUPON,
        "교환권이 곧 만료돼요",
        "이온음료 교환권 · 내일 23:59까지",
        "어제", isUnread = false, count = 3,
    ),
    MyFisNotification(
        5, MyFisNotification.Kind.GROUP,
        "새벽 러닝크루에 새 글이 올라왔어요",
        "내일 비 오면 실내 트랙으로 갈게요",
        "어제", isUnread = false,
    ),
    MyFisNotification(
        6, MyFisNotification.Kind.MEMBERSHIP,
        "회원권이 7일 남았어요",
        "6개월 회원권 · 9월 3일 만료",
        "3일 전", isUnread = false,
    ),
    MyFisNotification(
        7, MyFisNotification.Kind.NOTICE,
        "광복절 정상 운영합니다",
        "8월 15일 · 06:00 ~ 23:00",
        "5일 전", isUnread = false,
    ),
)
