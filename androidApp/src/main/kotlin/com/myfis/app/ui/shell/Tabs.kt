package com.myfis.app.ui.shell

import androidx.annotation.DrawableRes
import com.myfis.app.R

/**
 * SPEC.md §3 탭 구조.
 *
 * 웨이트 탭을 누르면 하단 탭 세트가 통째로 교체된다 (DESIGN.md §9 의도된 이탈 #4).
 * 되돌리자고 하지 말 것 — 운동 중에는 스토어·마이가 방해된다는 판단이다.
 */
enum class TabSet { BASE, WEIGHT }

sealed interface Tab {
    val label: String
    @get:DrawableRes val icon: Int
}

/** 기본 세트: 홈 / 혜택 / 스토어 / 웨이트 / 마이 */
enum class BaseTab(override val label: String, @DrawableRes override val icon: Int) : Tab {
    HOME("홈", R.drawable.ic_tab_home),
    BENEFIT("혜택", R.drawable.ic_tab_benefit),
    STORE("스토어", R.drawable.ic_tab_store),
    /** 누르면 탭 세트가 교체된다. 목적지가 아니라 통로다. */
    WEIGHT("웨이트", R.drawable.ic_tab_weight),
    MY("마이", R.drawable.ic_tab_my),
}

/** 웨이트 세트: 이전 / 웨이트 / 유산소 / 랭킹 / 모임 */
enum class WeightTab(override val label: String, @DrawableRes override val icon: Int) : Tab {
    /** 나가는 길. 항상 첫 번째 자리에 고정한다 (DESIGN.md §6.7). */
    BACK("이전", R.drawable.ic_tab_back),
    WEIGHT("웨이트", R.drawable.ic_tab_weight),
    CARDIO("유산소", R.drawable.ic_tab_cardio),
    RANKING("랭킹", R.drawable.ic_tab_ranking),
    GROUP("모임", R.drawable.ic_tab_group),
}
