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
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.myfis.app.ui.screens.GroupCreateScreen
import com.myfis.app.ui.screens.GroupIntroScreen
import com.myfis.app.ui.screens.RegionSearchScreen
import com.myfis.app.ui.screens.GroupScreen
import com.myfis.app.ui.screens.ActivityIntroScreen
import com.myfis.app.ui.screens.BenefitAction
import com.myfis.app.ui.screens.BenefitKind
import com.myfis.app.ui.screens.BenefitScreen
import com.myfis.app.ui.screens.BranchScreen
import com.myfis.app.ui.screens.CardioScreen
import com.myfis.app.ui.screens.HomeScreen
import com.myfis.app.ui.screens.NotificationScreen
import com.myfis.app.ui.screens.StoreCartScreen
import com.myfis.app.ui.screens.StoreItem
import com.myfis.app.ui.screens.StoreItemScreen
import com.myfis.app.ui.screens.StoreMyScreen
import com.myfis.app.ui.screens.StoreScreen
import com.myfis.app.ui.screens.WaterScreen
import com.myfis.app.ui.screens.waterDefaultTimes
import com.myfis.app.ui.screens.WaterTimeScreen
import com.myfis.app.ui.screens.WeightLogScreen
import com.myfis.app.ui.screens.WeightScreen
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
    // 상세로 넘길 상품. NavHost 인자로 객체를 실어 보낼 수 없어 셸이 들고 있는다
    var storeItem by remember { mutableStateOf<StoreItem?>(null) }
    // 물 마시기 미션 시각 — 두 화면이 나눠 쓴다. TODO(서버): 회원 설정으로 옮긴다 (SPEC P-05)
    var waterTimes by rememberSaveable { mutableStateOf(waterDefaultTimes) }
    // 검색은 잎이 아니라 **스토어의 모드**다 (§6.9). 상품 상세의 검색 버튼도 이걸 켠다
    var storeSearching by rememberSaveable { mutableStateOf(false) }
    // 랜딩에 띄울 활동. NavHost 인자로 객체를 실어 보낼 수 없어 셸이 들고 있는다 (상품 상세와 같다)
    var benefitAction by remember { mutableStateOf<BenefitAction?>(null) }
    // 개설 화면과 지역 설정이 나눠 쓴다 — 잎이 둘이라 셸이 들고 있는다 (상품 상세와 같다)
    var groupRegion by rememberSaveable { mutableStateOf<String?>(null) }

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
                onBranch = { nav.navigateOnce(Route.BRANCH) },
                onNotification = { nav.navigateOnce(Route.NOTIFICATIONS) },
                onStoreMy = { nav.navigateOnce(Route.STORE_MY) },
                onStoreCart = { nav.navigateOnce(Route.STORE_CART) },
                storeSearching = storeSearching,
                onStoreSearching = { storeSearching = it },
                onWeightLog = { nav.navigateOnce(Route.WEIGHT_LOG) },
                onGroupCreate = { nav.navigateOnce(Route.GROUP_CREATE) },
                onActivity = {
                    // 물 마시기는 **때가 정해진 미션**이라 랜딩을 거치지 않는다 (§6.25, 체중과 같은 처리)
                    if (it.kind == BenefitKind.WATER) {
                        nav.navigateOnce(Route.WATER)
                    } else {
                        benefitAction = it
                        nav.navigateOnce(Route.ACTIVITY_INTRO)
                    }
                },
                onStoreItem = {
                    storeItem = it
                    nav.navigateOnce(Route.STORE_ITEM)
                },
            )
        }
        composable(Route.ACTIVITY_INTRO) {
            // 뒤로 간 직후 한 프레임 동안 null 이 될 수 있어 방어한다
            benefitAction?.let {
                ActivityIntroScreen(action = it, onClose = { nav.popBackStack() })
            }
        }
        composable(Route.WATER) {
            WaterScreen(
                times = waterTimes,
                onClose = { nav.popBackStack() },
                onChangeTime = { nav.navigateOnce(Route.WATER_TIME) },
            )
        }
        composable(Route.WATER_TIME) {
            WaterTimeScreen(
                times = waterTimes,
                onSave = { waterTimes = it },
                onBack = { nav.popBackStack() },
            )
        }
        composable(Route.GROUP_CREATE) {
            // TODO(G-03 2단계): 소개·정원을 묻는 다음 장이 붙으면 `onNext` 를 잇는다
            GroupCreateScreen(
                region = groupRegion,
                onRegion = { groupRegion = it },
                onClose = { nav.popBackStack() },
                onSearchRegion = { nav.navigateOnce(Route.GROUP_REGION) },
                onNext = { _, _, _ -> nav.navigateOnce(Route.GROUP_INTRO) },
            )
        }
        composable(Route.GROUP_INTRO) {
            // TODO(서버): `모임 만들기` 가 실제로 모임을 만든다. 지금은 셸로 돌아간다
            GroupIntroScreen(
                onClose = { nav.popBackStack(Route.SHELL, false) },
                onBack = { nav.popBackStack() },
                onCreate = { nav.popBackStack(Route.SHELL, false) },
            )
        }
        composable(Route.GROUP_REGION) {
            RegionSearchScreen(
                onBack = { nav.popBackStack() },
                onPick = { groupRegion = it; nav.popBackStack() },
            )
        }
        composable(Route.WEIGHT_LOG) {
            WeightLogScreen(onBack = { nav.popBackStack() })
        }
        composable(Route.BRANCH) {
            BranchScreen(onBack = { nav.popBackStack() })
        }
        composable(Route.NOTIFICATIONS) {
            NotificationScreen(onBack = { nav.popBackStack() })
        }
        composable(Route.STORE_MY) {
            StoreMyScreen(
                onBack = { nav.popBackStack() },
                onCart = { nav.navigateOnce(Route.STORE_CART) },
            )
        }
        composable(Route.STORE_CART) {
            StoreCartScreen(
                onBack = { nav.popBackStack() },
                onStore = { nav.popBackStack() },
            )
        }
        composable(Route.STORE_ITEM) {
            // 뒤로 간 직후 한 프레임 동안 null 이 될 수 있어 방어한다
            storeItem?.let {
                StoreItemScreen(
                    item = it,
                    onBack = { nav.popBackStack() },
                    // 검색은 스토어의 모드라, 상세에서 누르면 **스토어로 돌아가 검색을 켠다**
                    onSearch = {
                        storeSearching = true
                        nav.popBackStack(Route.SHELL, false)
                    },
                    onCart = { nav.navigateOnce(Route.STORE_CART) },
                )
            }
        }
    }
}

/** 탭 셸 — 순검정 위에 헤더와 하단 탭 바. */
@Composable
private fun TabShell(
    onBranch: () -> Unit,
    onNotification: () -> Unit,
    onStoreMy: () -> Unit,
    onStoreCart: () -> Unit,
    storeSearching: Boolean,
    onStoreSearching: (Boolean) -> Unit,
    onWeightLog: () -> Unit,
    onGroupCreate: () -> Unit,
    onActivity: (BenefitAction) -> Unit,
    onStoreItem: (StoreItem) -> Unit,
) {
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
                    onBranch = onBranch,
                    onNotification = onNotification,
                    onStoreMy = onStoreMy,
                    onStoreCart = onStoreCart,
                    storeSearching = storeSearching,
                    onStoreSearching = onStoreSearching,
                    onWeightLog = onWeightLog,
                    onActivity = onActivity,
                    onStoreItem = onStoreItem,
                    // 홈의 유산소 바로가기 — 세트를 바꾸고 유산소로 바로 들어간다
                    onCardio = {
                        weightTab = WeightTab.CARDIO
                        tabSet = TabSet.WEIGHT
                    },
                    // 홈의 오늘의 루틴 카드 — 같은 길로 웨이트(W-01)에 들어간다
                    onWeight = {
                        weightTab = WeightTab.WEIGHT
                        tabSet = TabSet.WEIGHT
                    },
                    // 홈의 마일리지 상품 — 같은 세트 안이라 탭만 옮긴다
                    onStore = { baseTab = BaseTab.STORE },
                )
                TabSet.WEIGHT -> WeightTabContent(
                    tab = weightTab,
                    // 유산소의 `주문` 칸 — 세트를 되돌리고 스토어로 보낸다
                    onStore = {
                        baseTab = BaseTab.STORE
                        tabSet = TabSet.BASE
                    },
                    onGroupCreate = onGroupCreate,
                )
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
    onBranch: () -> Unit,
    onNotification: () -> Unit,
    onStoreMy: () -> Unit,
    onStoreCart: () -> Unit,
    storeSearching: Boolean,
    onStoreSearching: (Boolean) -> Unit,
    onWeightLog: () -> Unit,
    onActivity: (BenefitAction) -> Unit,
    onStoreItem: (StoreItem) -> Unit,
    onCardio: () -> Unit,
    onWeight: () -> Unit,
    onStore: () -> Unit,
) {
    when (tab) {
        BaseTab.HOME -> HomeScreen(
            onBranch = onBranch,
            onNotification = onNotification,
            onCardio = onCardio,
            onWeight = onWeight,
            onStore = onStore,
        )
        BaseTab.BENEFIT -> BenefitScreen(
            // **갈 곳이 있는 줄은 바로 보낸다** (§6.23, 2026-09-02 사용자 지정) —
            // 랜딩은 여기서 끝내고 돌아가는 활동의 몫이지, 다른 화면으로 가는 길목이 아니다
            onAction = {
                when (it.kind) {
                    BenefitKind.ROUTINE -> onWeight() // 홈의 `웨이트 하러 가기` 와 같은 길
                    BenefitKind.CARDIO -> onCardio() // 홈의 `유산소` 바로가기와 같은 길
                    BenefitKind.WEIGHT -> onWeightLog()
                    else -> onActivity(it) // 물 마시기는 onActivity 안에서 다시 갈린다
                }
            },
        )
        // 스토어 헤더의 '마이' 는 **마이 탭이 아니다.** 교환에 관한 나(S-08)로 간다.
        BaseTab.STORE -> StoreScreen(
            searching = storeSearching,
            onSearching = onStoreSearching,
            onMy = onStoreMy,
            onCart = onStoreCart,
            onItem = onStoreItem,
        )
        BaseTab.MY -> PlaceholderScreen("Y-01", "마이", "프로필 · 기록 · 설정")
        // 통로라 여기 도달하지 않는다
        BaseTab.WEIGHT -> Unit
    }
}

@Composable
private fun WeightTabContent(tab: WeightTab, onStore: () -> Unit, onGroupCreate: () -> Unit) {
    when (tab) {
        WeightTab.WEIGHT -> WeightScreen()
        // TODO(C-02): `유산소 시작하기` 는 기기 NFC 스캔이 붙으면 연결한다
        WeightTab.CARDIO -> CardioScreen(onStore = onStore)
        WeightTab.RANKING -> PlaceholderScreen("R-01", "랭킹", "웨이트 · 유산소 · 마일리지")
        WeightTab.GROUP -> GroupScreen(onCreate = onGroupCreate)
        WeightTab.BACK -> Unit
    }
}
