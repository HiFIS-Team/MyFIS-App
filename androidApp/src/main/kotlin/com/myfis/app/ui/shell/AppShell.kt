package com.myfis.app.ui.shell

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.myfis.app.ui.screens.HomeScreen
import com.myfis.app.ui.screens.NotificationScreen
import com.myfis.app.ui.screens.StoreMyScreen
import com.myfis.app.ui.screens.StoreScreen
import com.myfis.app.ui.theme.MyFisColor

/**
 * 앱의 뿌리.
 *
 * 탭 셸 위로 잎 화면이 **오른쪽에서 왼쪽으로 들어와 셸을 덮는다.**
 *
 * 셸은 움직이지 않는다 — 하단 탭 바가 같이 밀려 나갔다 돌아오면 그 왕복이 눈에 걸린다.
 * 덮개만 움직이면 돌아왔을 때 바가 원래 자리에 그대로 있다.
 * (`NavHost` 기본 전환은 700ms 크로스페이드라 직접 지정한다)
 */
@Composable
fun AppShell() {
    val nav = rememberNavController()

    NavHost(
        navController = nav,
        startDestination = Route.SHELL,
        modifier = Modifier.fillMaxSize().background(MyFisColor.BgBase),
        enterTransition = { slideInHorizontally(pushSpec) { it } },
        exitTransition = { ExitTransition.None },
        popEnterTransition = { EnterTransition.None },
        popExitTransition = { slideOutHorizontally(pushSpec) { it } },
    ) {
        composable(Route.SHELL) {
            TabShell(
                onNotification = { nav.navigateOnce(Route.NOTIFICATIONS) },
                onStoreMy = { nav.navigateOnce(Route.STORE_MY) },
            )
        }
        composable(Route.NOTIFICATIONS) {
            NotificationScreen(onBack = { nav.popBackStack() })
        }
        composable(Route.STORE_MY) {
            StoreMyScreen(onBack = { nav.popBackStack() })
        }
    }
}

/** 탭 셸 — 순검정 위에 헤더와 하단 탭 바. */
@Composable
private fun TabShell(onNotification: () -> Unit, onStoreMy: () -> Unit) {
    var tabSet by rememberSaveable { mutableStateOf(TabSet.BASE) }
    var baseTab by rememberSaveable { mutableStateOf(BaseTab.HOME) }
    var weightTab by rememberSaveable { mutableStateOf(WeightTab.WEIGHT) }

    Column(Modifier.fillMaxSize().background(MyFisColor.BgBase)) {
        // 헤더는 셸이 아니라 **화면마다** 다르다 (DESIGN.md §6.9).
        // 셸은 상태바 여백까지만 책임진다.
        Box(Modifier.weight(1f).statusBarsPadding()) {
            when (tabSet) {
                TabSet.BASE -> BaseTabContent(
                    tab = baseTab,
                    onNotification = onNotification,
                    onStoreMy = onStoreMy,
                )
                TabSet.WEIGHT -> WeightTabContent(weightTab)
            }
        }

        MyFisTabBar(
            tabSet = tabSet,
            baseTab = baseTab,
            weightTab = weightTab,
            onBaseSelect = { tab ->
                // 웨이트는 목적지가 아니라 통로다. baseTab 을 바꾸지 않아야
                // '이전' 으로 돌아왔을 때 보던 탭으로 복귀한다.
                if (tab == BaseTab.WEIGHT) tabSet = TabSet.WEIGHT else baseTab = tab
            },
            onWeightSelect = { tab ->
                if (tab == WeightTab.BACK) tabSet = TabSet.BASE else weightTab = tab
            },
        )
    }
}

@Composable
private fun BaseTabContent(
    tab: BaseTab,
    onNotification: () -> Unit,
    onStoreMy: () -> Unit,
) {
    when (tab) {
        BaseTab.HOME -> HomeScreen(onNotification = onNotification)
        BaseTab.BENEFIT -> PlaceholderScreen("P-01", "혜택", "보유 마일리지 · 적립 경로")
        // 스토어 헤더의 '마이' 는 **마이 탭이 아니다.** 교환에 관한 나(S-08)로 간다.
        BaseTab.STORE -> StoreScreen(onMy = onStoreMy)
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
