package com.myfis.app.ui.shell

import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.myfis.app.ui.theme.MyFisColor

/** 모든 화면이 올라앉는 배경. 순검정 위에 하단 탭 바만 있다. */
@Composable
fun AppShell() {
    var tabSet by rememberSaveable { mutableStateOf(TabSet.BASE) }
    var baseTab by rememberSaveable { mutableStateOf(BaseTab.HOME) }
    var weightTab by rememberSaveable { mutableStateOf(WeightTab.WEIGHT) }

    Column(Modifier.fillMaxSize().background(MyFisColor.BgBase)) {
        Box(Modifier.weight(1f).statusBarsPadding()) {
            when (tabSet) {
                TabSet.BASE -> BaseTabContent(baseTab)
                TabSet.WEIGHT -> WeightTabContent(weightTab)
            }
        }

        // 세트가 바뀌는 걸 사용자가 눈치채야 한다 — 탭 바만 크로스페이드 (DESIGN.md §6.7)
        Crossfade(targetState = tabSet, animationSpec = tween(200), label = "tabSet") { set ->
            when (set) {
                TabSet.BASE -> BottomTabBar(
                    tabs = BaseTab.entries,
                    selected = baseTab,
                    onSelect = { tab ->
                        // 웨이트는 목적지가 아니라 통로다. baseTab 을 바꾸지 않아야
                        // '이전' 으로 돌아왔을 때 보던 탭으로 복귀한다.
                        if (tab == BaseTab.WEIGHT) tabSet = TabSet.WEIGHT else baseTab = tab
                    },
                )

                TabSet.WEIGHT -> BottomTabBar(
                    tabs = WeightTab.entries,
                    selected = weightTab,
                    isExit = { it == WeightTab.BACK },
                    onSelect = { tab ->
                        if (tab == WeightTab.BACK) tabSet = TabSet.BASE else weightTab = tab
                    },
                )
            }
        }
    }
}

@Composable
private fun BaseTabContent(tab: BaseTab) {
    when (tab) {
        BaseTab.HOME -> PlaceholderScreen("H-01", "홈", "회원권 상태 · 오늘 할 운동 · 마일리지")
        BaseTab.BENEFIT -> PlaceholderScreen("P-01", "혜택", "보유 마일리지 · 적립 경로")
        BaseTab.STORE -> PlaceholderScreen("S-01", "스토어", "마일리지로 굿즈·음료 교환")
        BaseTab.MY -> PlaceholderScreen("Y-01", "마이", "프로필 · 기록 · 설정")
        // 통로라 여기 도달하지 않는다
        BaseTab.WEIGHT -> Unit
    }
}

@Composable
private fun WeightTabContent(tab: WeightTab) {
    when (tab) {
        WeightTab.WEIGHT -> PlaceholderScreen("W-01", "이번 주 루틴", "AI가 보낸 주간 루틴")
        WeightTab.CARDIO -> PlaceholderScreen("C-01", "유산소", "기기 목록 · NFC 스캔")
        WeightTab.RANKING -> PlaceholderScreen("R-01", "랭킹", "웨이트 · 유산소 · 마일리지")
        WeightTab.GROUP -> PlaceholderScreen("G-01", "모임", "모임 · 커뮤니티")
        WeightTab.BACK -> Unit
    }
}
