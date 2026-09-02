package com.myfis.app.ui.screens

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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
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
    onStart: () -> Unit = {},
) {
    var tab by rememberSaveable { mutableStateOf(CardioMissionTab.DAILY) }

    Column(Modifier.fillMaxSize()) {
        CardioHeader()

        Column(
            modifier = Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal),
        ) {
            MonthCard()
            ShortcutRow(onStore = onStore, modifier = Modifier.padding(top = MyFisSpacing.cardGap))
            MissionTabs(tab, { tab = it }, Modifier.padding(top = MyFisSpacing.sectionGap))
            MissionGrid(tab, Modifier.padding(top = MyFisSpacing.lg, bottom = MyFisSpacing.xxxl))
        }

        // 이 화면의 액션은 이 하나뿐 (§2 원칙 5) — 엄지가 닿는 자리에 못 박는다 (원칙 2)
        MyFisPrimaryButton(
            text = "유산소 시작하기",
            onClick = onStart,
            modifier = Modifier.padding(
                start = MyFisSpacing.screenHorizontal,
                end = MyFisSpacing.screenHorizontal,
                bottom = MyFisSpacing.md,
            ),
        )
    }
}

/**
 * **누구의 기록인지 밝히는 줄이다.**
 *
 * 다른 탭 헤더(§6.9)는 아이콘만 두지만 여기는 **내 몸의 기록**이라 이름이 앞에 온다.
 * 사진을 얼굴이 아니라 **색 원 + 첫 글자**로 대신한다 — P-07 레이더와 같은 규칙이다
 * (SPEC P-07 프라이버시: 실명·사진을 쓰지 않는다).
 */
@Composable
private fun CardioHeader() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp) // 헤더 높이 (§6.9) — 혜택·스토어 헤더와 같은 값
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(MyFisSize.chip)
                .background(MyFisColor.Surface3, MyFisRadius.full),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                cardioNamePlaceholder.take(1),
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
            )
        }
        Text(
            cardioNamePlaceholder,
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(start = MyFisSpacing.md),
        )
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
        Row(verticalAlignment = Alignment.Top) {
            Column(Modifier.weight(1f)) {
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
                Text(
                    cardioMonthKmPlaceholder,
                    style = MyFisTheme.type.metricXl,
                    color = MyFisColor.TextPrimary,
                    modifier = Modifier.padding(top = MyFisSpacing.md),
                )
                Text(
                    "km / month",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextTertiary,
                )
            }
            // 브랜드 마크는 **우리 도장**이다 — 원본의 네온 방패 자리
            Image(
                painter = painterResource(R.drawable.ic_stamp),
                contentDescription = null,
                modifier = Modifier.size(72.dp),
            )
        }
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

/** 뱃지 · 주문 — 원본의 `BADGE` / `ORDER` 두 칸. 좁은 칸 하나 + 넓은 칸 하나다 */
@Composable
private fun ShortcutRow(onStore: () -> Unit, modifier: Modifier = Modifier) {
    val storeInteraction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier.height(IntrinsicSize.Min),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        MyFisCard(Modifier.weight(5f).fillMaxHeight()) {
            Text(
                "BADGE",
                style = MyFisTheme.type.label,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.align(Alignment.CenterHorizontally),
            )
            Image(
                painter = painterResource(R.drawable.ic_stamp),
                contentDescription = null,
                modifier = Modifier
                    .padding(top = MyFisSpacing.md)
                    .align(Alignment.CenterHorizontally)
                    .size(48.dp),
            )
            Text(
                "1개 획득",
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
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier
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
    /** `0.03Km / 1Km` 처럼 **얼마나 남았는지**를 그대로 적는다 */
    val progress: String,
    val ratio: Float,
)

// TODO(서버): 이름·누적·미션 달성은 서버가 준다 (SPEC §8). 하드코딩하지 않는다
const val cardioNamePlaceholder = "은후"
const val cardioMonthKmPlaceholder = "12.4"

val cardioMissionPlaceholder = listOf(
    // 일간 — 하루 안에 끝나는 것. `첫 ~` 은 처음 한 번뿐이라 여기 못 온다
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_place_cardio,
        "오늘 3km", "0.4Km / 3Km", 0.13f,
    ),
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_place_machine,
        "계단 10분", "0분 / 10분", 0f,
    ),
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_quest_attend,
        "오늘 출석", "1일 / 1일", 1f,
    ),
    CardioMission(
        CardioMissionTab.DAILY, R.drawable.ic_quest_board,
        "기록 남기기", "0회 / 1회", 0f,
    ),
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_tab_cardio,
        "이번 주 5km", "3.2Km / 5Km", 0.64f,
    ),
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_quest_attend,
        "3일 나오기", "2일 / 3일", 0.66f,
    ),
    CardioMission(
        CardioMissionTab.WEEKLY, R.drawable.ic_place_machine,
        "계단 20분", "0분 / 20분", 0f,
    ),
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_tab_cardio,
        "이번 달 30km", "12.4Km / 30Km", 0.41f,
    ),
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_quest_attend,
        "12일 채우기", "5일 / 12일", 0.42f,
    ),
    CardioMission(
        CardioMissionTab.MONTHLY, R.drawable.ic_tab_ranking,
        "랭킹 100위", "142위 / 100위", 0.7f,
    ),
)
