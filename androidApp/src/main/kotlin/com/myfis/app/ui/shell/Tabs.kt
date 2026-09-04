package com.myfis.app.ui.shell

import androidx.annotation.DrawableRes
import com.myfis.app.R

/**
 * SPEC.md §3 탭 구조.
 *
 * 웨이트 탭을 누르면 하단 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
 * 되돌리지 말 것 — 운동 중에는 스토어·마이가 방해된다는 판단이다.
 */
enum class TabSet { BASE, WEIGHT }

sealed interface Tab {
    val label: String

    /** 비선택 — 아웃라인 */
    @get:DrawableRes val icon: Int

    /**
     * 선택 — **같은 실루엣의 안쪽이 찬 벌** (DESIGN.md §6.7).
     *
     * 선택은 색이 아니라 채움으로 알린다. 라임(`accent`)은 탭 바에서 쓰지 않는다.
     */
    @get:DrawableRes val iconFill: Int
}

/** 기본 세트: 홈 / 혜택 / 스토어 / 웨이트 / 마이 */
enum class BaseTab(
    override val label: String,
    @DrawableRes override val icon: Int,
    @DrawableRes override val iconFill: Int,
) : Tab {
    HOME("홈", R.drawable.ic_tab_home, R.drawable.ic_tab_home_fill),
    BENEFIT("혜택", R.drawable.ic_tab_benefit, R.drawable.ic_tab_benefit_fill),
    STORE("스토어", R.drawable.ic_tab_store, R.drawable.ic_tab_store_fill),
    /** 누르면 탭 세트가 교체된다. 목적지가 아니라 통로다. */
    WEIGHT("웨이트", R.drawable.ic_tab_weight, R.drawable.ic_tab_weight_fill),
    MY("마이", R.drawable.ic_tab_my, R.drawable.ic_tab_my_fill),
}

/** 웨이트 세트: 이전 / 웨이트 / 유산소 / 랭킹 / 모임 */
enum class WeightTab(
    override val label: String,
    @DrawableRes override val icon: Int,
    @DrawableRes override val iconFill: Int,
) : Tab {
    /**
     * 나가는 길. 항상 첫 번째 자리에 고정한다 (DESIGN.md §6.7).
     *
     * 선택되는 자리가 아니라 채움 벌이 없다 — 아웃라인 하나로 둔다.
     */
    BACK("이전", R.drawable.ic_tab_back, R.drawable.ic_tab_back),
    WEIGHT("웨이트", R.drawable.ic_tab_weight, R.drawable.ic_tab_weight_fill),
    CARDIO("유산소", R.drawable.ic_tab_cardio, R.drawable.ic_tab_cardio_fill),
    // **모임이 랭킹보다 앞이다** 🟢 (2026-09-04, 사용자 지정) — 자주 여는 순서다.
    // 랭킹은 하루 한 번 보고 마는 자리라 끝으로 민다
    GROUP("모임", R.drawable.ic_tab_group, R.drawable.ic_tab_group_fill),
    RANKING("랭킹", R.drawable.ic_tab_ranking, R.drawable.ic_tab_ranking_fill),
}
