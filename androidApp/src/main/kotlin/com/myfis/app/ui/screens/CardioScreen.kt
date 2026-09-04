package com.myfis.app.ui.screens

import android.graphics.ImageDecoder
import android.graphics.drawable.AnimatedImageDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.widget.ImageView
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.IntrinsicSize
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.myfis.app.R
import com.myfis.app.ui.components.MileageChip
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisProgress
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * SPEC.md C-01 유산소 탭 (DESIGN.md §6.28).
 *
 * 레퍼런스는 **버핏그라운드 유산소 탭**이다 (사용자 지정).
 * **뼈대만 가져오고 색은 우리 것을 쓴다** (§3.2) — 원본은 카드 아홉 장을 형광 초록으로
 * 채우지만 우리는 판을 어둡게 두고 **진행바에만 라임**을 쓴다 (§2 원칙 3).
 *
 * 이 탭이 답하는 질문은 둘 — **"이번 달 얼마나 뛰었지"** 와 **"다음에 뭘 하면 되지"**.
 * 한때 `이번 주 누적 → 빈 기기 → 최근 기록` 이었는데(§6.28 구안), 그건 **다 본 뒤에
 * 할 일이 없는 화면**이었다. 미션이 그 자리를 메운다.
 */
@Composable
fun CardioScreen(
    onStore: () -> Unit = {},
    // TODO(C-03): 태그를 읽으면 `운동 중` 으로 넘긴다. 지금은 시트에서 끝난다
) {
    var tab by rememberSaveable { mutableStateOf(CardioMissionTab.DAILY) }
    // 스캔은 잎 화면이 아니라 **이 화면 위에 덮이는 시트**다 (SPEC C-02) — 여기서 끝내고 돌아간다
    var scanning by rememberSaveable { mutableStateOf(false) }

    if (scanning) CardioScanSheet(onDismiss = { scanning = false })

    Column(Modifier.fillMaxSize()) {
        CardioHeader()

        Box(Modifier.weight(1f)) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = MyFisSpacing.screenHorizontal),
            ) {
                MonthCard()
                ShortcutRow(onStore = onStore, modifier = Modifier.padding(top = MyFisSpacing.cardGap))
                MissionTabs(tab, { tab = it }, Modifier.padding(top = MyFisSpacing.sectionGap))
                // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다
                MissionGrid(
                    tab,
                    Modifier.padding(
                        top = MyFisSpacing.lg,
                        bottom = MyFisSize.buttonSecondary + MyFisSpacing.xxxl,
                    ),
                )
            }

            // 이 화면의 액션은 이 하나뿐 (§2 원칙 5) — **오른쪽 아래**, 엄지가 닿는 자리다 (원칙 2).
            // 폭을 다 쓰면 **떠 있는 탭 바와 둥근 덩어리가 둘로 겹치므로** 알약으로 맞춘다 (§6.28)
            MyFisPrimaryButton(
                text = "유산소 시작하기",
                onClick = { scanning = true },
                pill = true,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = MyFisSpacing.screenHorizontal, bottom = MyFisSpacing.md),
            )
        }
    }
}

/**
 * **화면 이름 한 줄** 🟢 (2026-09-04, 사용자 지정).
 *
 * 전에는 `색 원 + 첫 글자 + 이름` 이었다 — *누구의 기록인지* 밝히려던 것인데,
 * **혼자 쓰는 앱에서 내 이름은 알려 주는 게 없다.** 웨이트 세트의 다른 탭(모임 §6.29)과
 * 같은 꼴로 **화면 이름**을 둔다. 오른쪽 칩은 그대로다 — 유산소는 뛴 만큼 P가 붙는다
 */
@Composable
private fun CardioHeader() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("유산소", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        MileageChip(balance = benefitBalancePlaceholder)
    }
}

/**
 * 이번 달 누적 — **이 화면의 주인공**이다 (§2 원칙 1).
 *
 * 주가 아니라 **달**로 센다 (2026-09-02 수정, 사용자 지정 레퍼런스) —
 * 유산소는 주 단위로 보면 0인 주가 흔해서 **숫자가 자주 비어 보인다.**
 */
@Composable
private fun MonthCard() {
    MyFisCard(shape = MyFisRadius.lg) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_cardio),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(20.dp),
            )
            Text(
                "이번 달",
                style = MyFisTheme.type.label,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(start = MyFisSpacing.sm),
            )
        }
        // 마크는 **숫자와 같은 줄**에 선다 — 위에 붙이면 라벨과 눈이 겹친다
        Row(
            modifier = Modifier.padding(top = MyFisSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                cardioMonthKmPlaceholder,
                style = MyFisTheme.type.metricXl,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.weight(1f),
            )
            // 브랜드 마크는 **도장이 아니라 로고**다 (2026-09-03, 사용자 지정).
            // 크기를 안 준다 — 밀도별로 구운 고유 크기(80×43dp)가 곧 규격이다
            Image(
                painter = painterResource(R.drawable.ic_logo),
                contentDescription = null,
            )
        }
        Text(
            "km / month",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
        )
        Row(
            modifier = Modifier.padding(top = MyFisSpacing.lg),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                "지금까지 ${cardioMonthKmPlaceholder}km 달렸어요",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.weight(1f),
            )
            Chevron()
        }
    }
}

/** 등급 · 주문 — 원본의 `BADGE` / `ORDER` 두 칸. 좁은 칸 하나 + 넓은 칸 하나다 */
@Composable
private fun ShortcutRow(onStore: () -> Unit, modifier: Modifier = Modifier) {
    val storeInteraction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier.height(IntrinsicSize.Min),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        MyFisCard(Modifier.weight(5f).fillMaxHeight()) {
            Text(
                "TIER",
                style = MyFisTheme.type.label,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.align(Alignment.CenterHorizontally),
            )
            Image(
                painter = painterResource(cardioTierPlaceholder.badge),
                contentDescription = null,
                modifier = Modifier
                    .padding(top = MyFisSpacing.md)
                    .align(Alignment.CenterHorizontally)
                    .size(48.dp),
            )
            Text(
                cardioTierPlaceholder.label,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier
                    .padding(top = MyFisSpacing.md)
                    .align(Alignment.CenterHorizontally),
            )
        }
        MyFisCard(
            Modifier
                .weight(8f)
                .fillMaxHeight()
                .tapWithHaptics(storeInteraction, onStore),
        ) {
            Box(Modifier.fillMaxWidth()) {
                Text(
                    "ORDER",
                    style = MyFisTheme.type.label,
                    color = MyFisColor.TextSecondary,
                    modifier = Modifier.align(Alignment.Center),
                )
                // 꺾쇠는 **얹는다** — 줄 안에 끼우면 가운데 글자가 왼쪽으로 밀린다
                Box(Modifier.align(Alignment.CenterEnd)) { Chevron() }
            }
            AnimatedDrink(
                Modifier
                    .padding(top = MyFisSpacing.md)
                    .align(Alignment.CenterHorizontally)
                    .size(48.dp),
            )
            Text(
                "운동하고 마실 것 주문하기",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier
                    .padding(top = MyFisSpacing.md)
                    .align(Alignment.CenterHorizontally),
            )
        }
    }
}

/**
 * 미션 갈래 줄 — `일간` · `주간` · `월간`.
 *
 * **밑줄이 칸을 따라 흐른다** — 스토어 카테고리(§6.12)와 같은 규칙이다.
 * 다만 스토어는 칸 폭이 제각각이라 **위치를 재야** 하지만,
 * 여기는 셋이 폭을 고르게 나눠 가지므로 **순번만 알면** 자리가 나온다.
 *
 * 고른 것은 색이 아니라 밑줄로 알린다 — 라임은 진행바와 버튼의 몫이다.
 */
@Composable
private fun MissionTabs(
    selected: CardioMissionTab,
    onSelect: (CardioMissionTab) -> Unit,
    modifier: Modifier = Modifier,
) {
    val tabs = CardioMissionTab.entries

    BoxWithConstraints(modifier.fillMaxWidth()) {
        val slot = maxWidth / tabs.size
        // 고르는 동작이라 `fast`(120ms) 다 — 스토어 밑줄과 같은 값 (§7)
        val barX by animateDpAsState(
            slot * tabs.indexOf(selected), MyFisMotion.fast(), label = "barX",
        )

        Row(Modifier.fillMaxWidth()) {
            tabs.forEach { tab ->
                val on = tab == selected
                val interaction = remember(tab) { MutableInteractionSource() }

                Text(
                    tab.title,
                    style = MyFisTheme.type.titleSm,
                    color = if (on) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                    textAlign = TextAlign.Center,
                    modifier = Modifier
                        .weight(1f)
                        .tapWithHaptics(interaction) { onSelect(tab) }
                        .padding(vertical = MyFisSpacing.md),
                )
            }
        }

        // 바닥 줄이 세 칸을 하나로 묶는다 — 없으면 막대가 허공에서 움직인다
        Box(
            Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
        Box(
            Modifier
                .align(Alignment.BottomStart)
                .offset(x = barX)
                .width(slot)
                .height(2.dp)
                .background(MyFisColor.TextPrimary),
        )
    }
}

/** 미션 칸 세 줄짜리 격자. 줄 수가 적어 `LazyVerticalGrid` 를 쓰지 않는다 (화면이 통째로 스크롤한다) */
@Composable
private fun MissionGrid(tab: CardioMissionTab, modifier: Modifier = Modifier) {
    val rows = cardioMissionPlaceholder.filter { it.tab == tab }.chunked(3)

    Column(modifier, verticalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
        rows.forEach { row ->
            Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
                row.forEach { MissionCard(it, Modifier.weight(1f)) }
                // 마지막 줄이 덜 찼으면 빈 칸으로 채운다 — 남은 칸이 늘어나면 안 된다
                repeat(3 - row.size) { Spacer(Modifier.weight(1f)) }
            }
        }
    }
}

/**
 * 미션 한 칸.
 *
 * ⚠️ **판을 라임으로 채우지 않는다.** 원본은 칸을 통째로 형광 초록으로 채우는데,
 * 그러면 아홉 칸이 전부 액센트라 **어느 것도 강조가 아니게 된다** (§2 원칙 3).
 * 라임은 **진행바 한 줄**에만 준다 — 그게 이 칸에서 유일하게 변하는 값이다.
 */
@Composable
private fun MissionCard(mission: CardioMission, modifier: Modifier = Modifier) {
    MyFisCard(modifier) {
        Icon(
            painter = painterResource(mission.icon),
            contentDescription = null,
            tint = MyFisColor.TextSecondary,
            modifier = Modifier
                .align(Alignment.CenterHorizontally)
                .size(28.dp),
        )
        Text(
            mission.title,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.md),
        )
        Text(
            mission.progress,
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextTertiary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = 2.dp),
        )
        MyFisProgress(mission.ratio, Modifier.padding(top = MyFisSpacing.md))
    }
}

/**
 * `ORDER` 칸의 움직이는 잔 (사용자 제공, 2026-09-03).
 *
 * **플랫폼이 주는 디코더를 그대로 쓴다** (§2 원칙 6) — `ImageDecoder` 가 움직이는 WebP 를
 * `AnimatedImageDrawable` 로 풀어 준다. 그림 라이브러리를 붙이지 않는다.
 *
 * ⚠️ 원본 GIF 는 **알파가 없어** 흰 바탕이 통째로 들어 있었다. 어두운 판에 얹으면 흰 네모가 된다 —
 * 모서리에서 번지는 흰 영역만 지우고(잔 안의 흰 하이라이트는 살린다) **알파 있는 WebP** 로 다시 구웠다.
 *
 * ⚠️⚠️ **여는 순간이 끊기던 원인이 여기였다** 🟢 (2026-09-04). 프레임 57장짜리를
 * `factory` 안에서 풀고 있었는데 그 자리가 **메인 스레드**다. `IO` 로 옮기고,
 * 다 풀릴 때까지는 **빈 자리로 둔다** — 기다리느라 화면을 잡지 않는다.
 */
@Composable
private fun AnimatedDrink(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    var drink by remember { mutableStateOf<Drawable?>(null) }

    LaunchedEffect(Unit) {
        drink = withContext(Dispatchers.IO) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                ImageDecoder.decodeDrawable(
                    ImageDecoder.createSource(context.resources, R.drawable.ic_order_drink),
                )
            } else {
                // API 27 이하는 첫 프레임만 나온다 — 안 움직일 뿐 그림은 맞다
                context.getDrawable(R.drawable.ic_order_drink)
            }
        }
    }

    AndroidView(
        modifier = modifier,
        factory = { ImageView(it) },
        update = { view ->
            if (view.drawable !== drink) {
                view.setImageDrawable(drink)
                (drink as? AnimatedImageDrawable)?.start()
            }
        },
    )
}

/** 오른쪽 꺾쇠 — 아래 꺾쇠를 돌려 쓴다 (§6.28 구안과 같은 방법) */
@Composable
private fun Chevron() {
    Icon(
        painter = painterResource(R.drawable.ic_chevron_down),
        contentDescription = null,
        tint = MyFisColor.TextTertiary,
        modifier = Modifier
            .size(20.dp)
            .rotate(-90f),
    )
}

/** 미션 갈래 (SPEC C-01) */
enum class CardioMissionTab(val title: String) {
    DAILY("일간"),
    WEEKLY("주간"),
    MONTHLY("월간"),
}

/** 미션 한 칸 (SPEC C-01) */
data class CardioMission(
    val tab: CardioMissionTab,
    val icon: Int,
    val title: String,
    /**
     * `0.4 / 2km` 처럼 **얼마나 남았는지**를 적는다.
     * 단위는 **목표 쪽에 한 번만** 붙인다 — 3열 칸에서 양쪽에 다 붙이면 잘린다 (2026-09-04)
     */
    val progress: String,
    val ratio: Float,
)

// TODO(서버): 이름·누적·미션 달성은 서버가 준다 (SPEC §8). 하드코딩하지 않는다
const val cardioMonthKmPlaceholder = "12.4"

/**
 * 등급 — 여섯 (사용자 제공 뱃지, 2026-09-03).
 *
 * 뱃지는 **원색 그림**이라 칠하지 않는다 (§6.23 원색 아이콘과 같은 규칙).
 * 갈래 색(`category.*`)을 붙이지 않는 것도 같은 이유다 — **금속 자체가 등급을 말한다.**
 */
enum class CardioTier(val label: String, val badge: Int) {
    BRONZE("브론즈", R.drawable.ic_tier_bronze),
    SILVER("실버", R.drawable.ic_tier_silver),
    GOLD("골드", R.drawable.ic_tier_gold),
    PLATINUM("플래티넘", R.drawable.ic_tier_platinum),
    DIAMOND("다이아", R.drawable.ic_tier_diamond),
    MASTER("마스터", R.drawable.ic_tier_master),
}

/** 🔵 무엇으로 등급이 오르는지는 아직 안 정했다 — 값만 자리를 잡아 둔 것이다 */
val cardioTierPlaceholder = CardioTier.SILVER

/**
 * 갈래마다 **앞세우는 지표를 다르게 둔다** 🟢 (2026-09-04).
 *
 * 전에는 셋 다 km 였다 — 일간 3km · 주간 5km · 월간 30km. 갈래를 바꿔도 새로운 게 없고,
 * 숫자도 서로 안 맞았다(하루 3km 면 주간 5km 는 이틀이면 끝난다).
 *
 * | 갈래 | 답하는 질문 | 앞세우는 지표 |
 * |------|------------|--------------|
 * | 일간 | 오늘 이거 하나만 | **시간** — 거리로 재면 사이클·계단이 손해다 |
 * | 주간 | 빠지지 않았나 | **일수** — 하루 못 해도 만회된다 |
 * | 월간 | 지난달보다 나아졌나 | **누적 거리** |
 *
 * 갈래마다 **세 칸 고정**이다. 넷이면 두 줄이 되어 갈래를 바꿀 때 화면 높이가 흔들린다.
 * ⚠️ 제목은 **한 줄이다.** 3열이라 글자 예산이 한글 여섯 자쯤뿐이다 — 넘기면 `…` 로 잘린다.
 * 같은 지표는 같은 아이콘을 쓴다 — 칸을 안 읽어도 무엇을 재는지 보인다.
 *
 * **뺀 것들**: `오늘 출석`(혜택 P-01 과 중복) · `기록 남기기`(C-03 이 자동으로 남긴다) ·
 * `랭킹 100위`(**남이 안 뛰어야 끝나는 미션이다.** 랭킹은 R-01 이 따로 있고 서버에도 없다) ·
 * `계단 10분`(그 기구가 차 있으면 못 한다 → `기구 두 대`로 바꿨다)
 */
val cardioMissionPlaceholder = listOf(
    // 일간 — 오늘 안에 끝난다. 문턱을 낮게 둔다
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_place_cardio,
        "20분 채우기", "0 / 20분", 0f,
    ),
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_tab_cardio,
        "2km 채우기", "0.4 / 2km", 0.2f,
    ),
    // 한 기구만 붙잡고 있지 말라는 유도다
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_place_machine,
        "기구 2대 타기", "1 / 2대", 0.5f,
    ),

    // 주간 — 며칠 나왔나. 일간 목표에서 그대로 곱해 나온 수다
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_quest_attend,
        "3일 나오기", "2 / 3일", 0.66f,
    ),
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_place_cardio,
        "100분 채우기", "40 / 100분", 0.4f,
    ),
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_tab_cardio,
        "이번 주 15km", "3.2 / 15km", 0.21f,
    ),

    // 월간 — 누적과 성장. 주간 목표 × 4 다
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_tab_cardio,
        "이번 달 60km", "12.4 / 60km", 0.21f,
    ),
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_quest_attend,
        "12일 나오기", "5 / 12일", 0.42f,
    ),
    // **남이 아니라 나와 견준다** — 누구나 끝낼 수 있고 목표가 매달 저절로 갱신된다
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_quest_board,
        "기록 깨기", "12.4 / 48km", 0.26f,
    ),
)
