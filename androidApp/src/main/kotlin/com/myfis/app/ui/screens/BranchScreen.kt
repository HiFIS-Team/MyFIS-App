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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
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
 * 지금은 **찾기 줄 + 빠른 고르기**까지다. 밑에 들어갈 평면도 · 기구 핀은 아직 미정이다.
 *
 * 줄의 짜임은 **카카오 T 홈**에서 가져왔다 (사용자 지정) —
 * 큰 알약 하나에 **물음 한 줄**. 색은 우리 것을 쓴다.
 *
 * ⚠️ 잎 화면은 셸 밖이라 **바탕색과 상태바 여백을 스스로 넣는다.**
 * 바탕이 없으면 밀려 들어오는 동안 뒤 화면이 비쳐 겹쳐 보이고, 여백이 없으면 헤더가 시계에 겹친다.
 */
@Composable
fun BranchScreen(onBack: () -> Unit = {}) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(title = "기구 찾기", onBack = onBack)

        BranchSearchBar(
            Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.sm),
        )

        PlaceQuickPick(
            Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.xl),
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
private enum class BranchPlace(
    val icon: Int,
    val title: String,
    /**
     * **자기 색을 가진 그림**이라 tint 를 걸지 않는다 (§8 원색 벌).
     *
     * 색이 붙는 기준은 둘 중 하나다 — **① 색이 곧 뜻인 표지판**(화장실의 파랑·분홍은
     * 남녀 표시 그 자체, 탈의실 커튼은 색이 빠지면 창문으로 읽힌다),
     * **② 사용자가 준 원본이 원색인 것**(나머지 전부).
     *
     * 지금은 **샤워실만** 단색이다 — 원본을 아직 안 받았다.
     */
    val colorIcon: Boolean = false,
) {
    FREE(R.drawable.ic_place_free, "프리웨이트", colorIcon = true),
    MACHINE(R.drawable.ic_place_machine, "머신", colorIcon = true),
    CARDIO(R.drawable.ic_place_cardio, "유산소", colorIcon = true),
    STRETCH(R.drawable.ic_place_stretch, "스트레칭", colorIcon = true),
    TOILET(R.drawable.ic_place_toilet, "화장실", colorIcon = true),
    SHOWER(R.drawable.ic_place_shower, "샤워실"),
    FITTING(R.drawable.ic_place_fitting, "탈의실", colorIcon = true),
    DESK(R.drawable.ic_place_desk, "데스크", colorIcon = true),
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
                row.forEach { PlaceCell(it, Modifier.weight(1f)) }
            }
        }
    }
}

/**
 * 아이콘 판 + 라벨. 판의 짜임은 **혜택 행과 같다** (§6.23) — 같은 물건은 같게 그린다.
 *
 * 아이콘은 **기본이 단색 아웃라인**이고, 표지판인 둘만 원색이다 (`colorIcon`).
 * 라임은 안 쓴다 — 이 화면의 액센트는 찾기 줄 테두리 하나다 (§3.2 액센트 예산).
 */
@Composable
private fun PlaceCell(place: BranchPlace, modifier: Modifier = Modifier) {
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
            // 원색 벌은 **`Image`** 로 그린다 — `Icon` 은 tint 로 한 색을 덮어씌운다
            if (place.colorIcon) {
                Image(
                    painter = painterResource(place.icon),
                    contentDescription = null, // 밑의 라벨이 이름 역할을 한다
                    modifier = Modifier.size(28.dp),
                )
            } else {
                Icon(
                    painter = painterResource(place.icon),
                    contentDescription = null,
                    tint = MyFisColor.TextPrimary,
                    modifier = Modifier.size(28.dp),
                )
            }
        }

        Text(
            place.title,
            style = MyFisTheme.type.label,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}
