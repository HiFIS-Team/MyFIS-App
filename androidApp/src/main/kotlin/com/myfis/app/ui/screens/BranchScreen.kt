package com.myfis.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.BottomSheetScaffold
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.SheetValue
import androidx.compose.material3.Text
import androidx.compose.material3.rememberBottomSheetScaffoldState
import androidx.compose.material3.rememberStandardBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 홈 헤더의 **핀으로 들어오는 잎 화면** (SPEC M-08 지점 내부 지도).
 *
 * 짜임은 **지도 앱 방식**이다 🟢 (2026-08-27) — 평면도가 화면을 채우고,
 * 찾기 줄은 그 위에 뜨고, 고르는 것들은 **바닥 시트** 안으로 들어간다.
 *
 * ⚠️ 처음엔 위에서부터 찾기 줄 → 빠른 고르기 → 자주 쓰는 기구 → 지도로 쌓았는데,
 * 그러면 지도에 **280dp** 밖에 안 남았다. 이 화면의 북극성은 "쉬는 시간 20초 안에"인데
 * 지도를 보려고 스크롤해야 하면 그 자체로 실패다 (SPEC M-08).
 *
 * 시트는 **`BottomSheetScaffold`** 다 — 끌기 · 멈춤 · 그림자를 플랫폼이 준다 (§2 원칙 6).
 *
 * ⚠️ 잎 화면은 셸 밖이라 **바탕색과 상태바 여백을 스스로 넣는다.**
 * 바탕이 없으면 밀려 들어오는 동안 뒤 화면이 비쳐 겹쳐 보이고, 여백이 없으면 헤더가 시계에 겹친다.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BranchScreen(onBack: () -> Unit = {}) {
    val state = rememberBottomSheetScaffoldState(
        bottomSheetState = rememberStandardBottomSheetState(
            initialValue = SheetValue.PartiallyExpanded,
            // 접힌 자리로 못 내려가게 막는다 — 내려가면 지도만 남고 고를 데가 사라진다
            skipHiddenState = true,
        ),
    )

    BottomSheetScaffold(
        scaffoldState = state,
        // 접혔을 때 **빠른 고르기 두 줄이 다 보인다.** 한 줄만 보이게 하면 나머지 넷이
        // 있는 줄 모르고, 더 올리면 지도가 반으로 줄어든다 (손잡이 + 두 줄 + 바닥 여백)
        sheetPeekHeight = 264.dp,
        sheetContainerColor = MyFisColor.Surface1,
        sheetContentColor = MyFisColor.TextPrimary,
        sheetShape = MyFisRadius.sheet,
        sheetShadowElevation = 0.dp,
        containerColor = MyFisColor.BgBase,
        sheetContent = {
            Column(
                Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .padding(bottom = MyFisSpacing.xxxl)
                    .navigationBarsPadding(),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xxl),
            ) {
                PlaceQuickPick()
                FavoriteMachines()
            }
        },
    ) {
        Box(
            Modifier
                .fillMaxSize()
                .background(MyFisColor.BgBase)
                .statusBarsPadding(),
        ) {
            // 평면도가 **바탕**이다. 헤더 · 찾기 줄이 그 위에 얹힌다
            BranchMap()

            Column {
                DetailHeader(title = "기구 찾기", onBack = onBack)

                BranchSearchBar(
                    Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = MyFisSpacing.sm),
                )
            }
        }
    }
}

/**
 * 평면도 자리. **아직 그림이 없다** — SPEC M-08 의 빈 상태를 그대로 쓴다.
 *
 * 바탕을 `bg.base` 로 두는 건 위에 얹힐 시트(`surface.1`)와 갈라 보이게 하려는 것이다 (§5.4).
 */
@Composable
private fun BranchMap() {
    // TODO: 평면도 + 기구 핀 (M-08). "재지 않고 보고 그린다"로 정해 뒀다
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(
            "이 지점은 지도가 아직 없어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
        )
    }
}

/**
 * 찾기 줄 — **이 화면에서 제일 먼저 눈에 들어와야 하는 것**이라 테두리를 라임으로 두른다.
 *
 * 판을 라임으로 채우지 않는다. 채우면 밑에 올 지도보다 이 줄이 더 세진다 (§3.2 액센트 예산).
 */
@Composable
private fun BranchSearchBar(modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(MyFisSize.searchBar)
            .background(MyFisColor.Surface1, MyFisRadius.lg)
            .border(1.5.dp, MyFisColor.Accent, MyFisRadius.lg)
            .padding(horizontal = MyFisSpacing.lg),
        contentAlignment = Alignment.CenterStart,
    ) {
        // TODO: 누르면 기구 검색으로 (M-08). 지금은 자리만 잡는다
        // 물음이 **이 줄의 제목**이라 흐리게 두지 않는다. tertiary 로 두면 꺼진 칸처럼 보인다
        Text(
            "어떤 기구 찾으세요?",
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/**
 * 빠른 고르기 여덟 칸 (DESIGN §6.26).
 *
 * **구역**이지 기구 낱개가 아니다 🟢 (2026-08-27). 기구 하나하나는 위 **찾기 줄**이 맡고,
 * 이 판은 지도의 **구역과 1:1** 로 맞춘다 — 스쿼트랙 · 벤치 · 덤벨은 셋 다 프리웨이트존 안이라
 * 나란히 놓을 것이 아니었다. 앞 넷은 운동 구역, 뒤 넷은 편의시설이다.
 */
private enum class BranchPlace(val icon: Int, val title: String) {
    FREE(R.drawable.ic_place_free, "프리웨이트"),
    MACHINE(R.drawable.ic_place_machine, "머신"),
    CARDIO(R.drawable.ic_place_cardio, "유산소"),
    STRETCH(R.drawable.ic_place_stretch, "스트레칭"),
    TOILET(R.drawable.ic_place_toilet, "화장실"),
    SHOWER(R.drawable.ic_place_shower, "샤워실"),
    FITTING(R.drawable.ic_place_fitting, "탈의실"),
    DESK(R.drawable.ic_place_desk, "데스크"),
}

/**
 * **네 칸 × 두 줄.** 한 줄에 다섯을 넣으면 라벨(`프리웨이트`)이 줄어들고,
 * 셋으로 줄이면 판이 커져 밑에 올 지도를 밀어낸다.
 *
 * 여덟 칸뿐이라 `LazyVerticalGrid` 를 쓰지 않는다 — 세로 스크롤이 둘이 되면 지도와 부딪힌다.
 */
@Composable
private fun PlaceQuickPick(modifier: Modifier = Modifier) {
    Column(
        modifier = modifier.fillMaxWidth(),
        // 줄 사이는 16 이다. 칸 사이(12)보다 넓어야 라벨이 아래 판에 붙지 않는다
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        BranchPlace.entries.chunked(4).forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
                row.forEach { PlaceCell(it.icon, it.title, Modifier.weight(1f)) }
            }
        }
    }
}

/**
 * 아이콘 판 + 라벨. 판의 짜임은 **혜택 행과 같다** (§6.23) — 같은 물건은 같게 그린다.
 *
 * 아이콘은 **여덟이 전부 원색**이라 tint 를 걸지 않는다 (§8).
 * 라임은 안 쓴다 — 이 화면의 액센트는 찾기 줄 테두리 하나다 (§3.2 액센트 예산).
 */
@Composable
private fun PlaceCell(icon: Int, title: String, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // TODO: 누르면 그 갈래를 지도에서 집는다 (M-08)
        modifier = modifier.tapWithHaptics(interaction) {},
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Box(
            Modifier
                .size(MyFisSize.listRowMin)
                .background(MyFisColor.Surface2, MyFisRadius.tile)
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.tile),
            contentAlignment = Alignment.Center,
        ) {
            // ⚠️ 원색 벌은 **`Image`** 로 그린다 — `Icon` 은 tint 로 한 색을 덮어씌운다
            Image(
                painter = painterResource(icon),
                contentDescription = null, // 밑의 라벨이 이름 역할을 한다
                modifier = Modifier.size(28.dp),
            )
        }

        Text(
            title,
            style = MyFisTheme.type.label,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/**
 * 자주 쓰는 기구 — **꽂아 둔 기구로 바로 가는 자리** (DESIGN §6.27).
 *
 * 짜임은 **카카오 T `자주 쓰는 서비스`** 에서 가져왔다 (사용자 지정) —
 * 카드 하나에 제목 + `편집`, 그 밑에 칸 넷. 빈 칸은 **압정**으로 자리를 보여 준다.
 *
 * ⚠️ 레퍼런스는 칸이 다섯인데 **넷으로 줄였다.** 위 빠른 고르기가 4열이라 다섯을 두면
 * 판이 어긋나 두 묶음이 따로 노는 것처럼 보인다.
 */
@Composable
private fun FavoriteMachines(modifier: Modifier = Modifier) {
    // ⚠️ 여기 이름은 **기구**다. 위 빠른 고르기는 구역(`프리웨이트`)인데
    // 여기까지 구역 이름을 쓰면 "자주 쓰는 기구"라는 제목과 어긋난다
    // TODO: 꽂아 둔 기구를 서버에서 받는다 (M-08). 지금은 보여 주기용이다
    val pinned = listOf(
        R.drawable.ic_place_free to "벤치프레스",
        R.drawable.ic_place_cardio to "러닝머신",
    )
    val interaction = remember { MutableInteractionSource() }

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface1, MyFisRadius.md)
            .padding(MyFisSpacing.cardPadding),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        Row(
            Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Text(
                "자주 쓰는 기구",
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.weight(1f),
            )
            // TODO: 꽂기/빼기 편집으로 (M-08)
            Text(
                "편집",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.tapWithHaptics(interaction) {},
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
            repeat(4) { index ->
                if (index < pinned.size) {
                    val (icon, title) = pinned[index]
                    PlaceCell(icon, title, Modifier.weight(1f))
                } else {
                    EmptyPinSlot(Modifier.weight(1f))
                }
            }
        }
    }
}

/**
 * 빈 칸. **자리를 비워 두지 않고 압정을 놓는다** — 비워 두면 칸이 몇 개인지 안 보이고,
 * 꽂을 수 있다는 것도 안 보인다.
 */
@Composable
private fun EmptyPinSlot(modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // TODO: 누르면 기구 고르기로 (M-08)
        modifier = modifier.tapWithHaptics(interaction) {},
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Box(
            Modifier
                .size(MyFisSize.listRowMin)
                .background(MyFisColor.Surface2, MyFisRadius.tile)
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.tile),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_place_pin),
                contentDescription = null, // 밑의 라벨이 이름 역할을 한다
                // 찬 칸(28 원색)보다 작고 흐리다. 같은 무게로 두면 빈 칸이 먼저 읽힌다
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(24.dp),
            )
        }

        Text("추가", style = MyFisTheme.type.label, color = MyFisColor.TextTertiary, maxLines = 1)
    }
}
