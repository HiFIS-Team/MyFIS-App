package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md C-01 유산소 탭 (DESIGN.md §6.28).
 *
 * **보러 오는 건 숫자다.** 기기가 비었는지는 고개만 들면 보인다 —
 * 그래서 맨 위가 `이번 주 누적`이고, 기기 현황은 **한 줄**이다.
 *
 * ⚠️ 원래 명세는 `유산소 시작`(기기 목록 + 스캔)이었는데 **탭 하나를 차지할 무게가
 * 아니었다.** 웨이트 탭은 AI 주간 루틴 세션인데 여기가 기계 목록이면 둘의 무게가 안 맞는다.
 * 기록(C-05)을 마이 메뉴에서 이 탭으로 끌어올렸다.
 */
@Composable
fun CardioScreen(
    onBranch: () -> Unit = {},
    onHistory: () -> Unit = {},
    onScan: () -> Unit = {},
) {
    Column(Modifier.fillMaxSize()) {
        CardioHeader(onBranch)

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.lg, bottom = MyFisSpacing.xxxl),
            verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sectionGap),
        ) {
            WeekSummary(CardioPlaceholder.week)
            AvailableRow(CardioPlaceholder.available, onBranch)
            RecentSessions(CardioPlaceholder.recent, onHistory)
        }

        // ④ **화면당 주요 액션은 이 하나뿐**이다 (§2 원칙 5).
        // 엄지가 닿는 아래에 못 박는다 (원칙 2) — 스크롤을 따라 올라가지 않는다
        MyFisPrimaryButton(
            text = "기기 스캔하기",
            onClick = onScan,
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.sm),
        )
    }
}

/**
 * **아이콘 줄이다** — 탭 화면에는 글자 제목을 두지 않는다 (§6.9).
 *
 * 지점 이름을 둔 건 제목이 아니라 **값**이라서다 — 빈 기기 수가 어느 지점 것인지
 * 밝히지 않으면 아래 한 줄을 믿을 수 없다.
 */
@Composable
private fun CardioHeader(onBranch: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            Modifier
                .tapWithHaptics(interaction, onBranch)
                .padding(horizontal = MyFisSpacing.sm)
                .height(MyFisSize.buttonSmall),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_header_branch),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(20.dp),
            )
            Text(
                CardioPlaceholder.branch,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
            )
        }
    }
}

/**
 * ① 이 화면의 주인공. **숫자가 제일 크다** (§2 원칙 1).
 *
 * ⚠️ 진행률 고리를 안 붙인다 — **주간 목표가 아직 없다.**
 * 없는 채로 눈금만 두면 **채울 수 없는 눈금**이 된다 (SPEC C-01).
 */
@Composable
private fun WeekSummary(week: CardioWeek) {
    Column(Modifier.fillMaxWidth()) {
        Text("이번 주", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)

        Row(
            Modifier.padding(top = MyFisSpacing.xs),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Text(week.distance, style = MyFisTheme.type.metricLg, color = MyFisColor.Accent)
            Text(
                "km",
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(bottom = MyFisSpacing.xs),
            )
        }

        // 지난주가 없으면 아예 뺀다. `+0.0` 은 정보가 아니라 잡음이다
        week.delta?.let {
            Text(
                it,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(top = MyFisSpacing.xs),
            )
        }
    }
}

/**
 * ② **한 줄이다.** 번호 칩을 늘어놓으면 화면은 차는데 어디 있는지는 여전히 모른다 —
 * `런닝머신 3번`이 어느 자리인지 아는 사람은 이미 그 헬스장을 아는 사람이다.
 * 숫자만 두고 **위치는 지도(M-08)에 맡긴다.**
 */
@Composable
private fun AvailableRow(counts: List<CardioCount>, onTap: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    MyFisCard {
        Text("지금 비어 있어요", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)

        Row(
            Modifier.padding(top = MyFisSpacing.sm),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            counts.forEach { count ->
                Row(
                    verticalAlignment = Alignment.Bottom,
                    horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
                ) {
                    Text(
                        count.name,
                        style = MyFisTheme.type.body,
                        color = MyFisColor.TextPrimary,
                        modifier = Modifier.padding(bottom = 2.dp),
                    )
                    Text(
                        "${count.free}",
                        style = MyFisTheme.type.metricMd,
                        color = MyFisColor.TextPrimary,
                    )
                }
            }
        }

        // Ghost 다. Primary 처럼 보이면 화면에 주요 액션이 둘이 된다 (§2 원칙 5)
        Row(
            Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.xs)
                .height(MyFisSize.minTouchTarget)
                .tapWithHaptics(interaction, onTap),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Text("카디오존 보기", style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            // 오른쪽 꺾쇠는 **아래 꺾쇠를 돌려 쓴다** — 집 안에서 쓰는 방식이다
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier
                    .size(14.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

/** ③ 최근 셋만. 전부 보려면 C-05 로 간다 — **여기가 그 화면의 본진 입구**다 */
@Composable
private fun RecentSessions(rows: List<CardioSessionRow>, onMore: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Column(Modifier.fillMaxWidth()) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                "최근 기록",
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.weight(1f),
            )
            Text(
                "전체 보기",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.tapWithHaptics(interaction, onMore),
            )
        }

        rows.forEach { row ->
            Row(
                Modifier
                    .fillMaxWidth()
                    .height(MyFisSize.listRowMin),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
            ) {
                Text(
                    row.date,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextTertiary,
                    modifier = Modifier.width(42.dp),
                )
                Text(
                    row.machine,
                    style = MyFisTheme.type.body,
                    color = MyFisColor.TextPrimary,
                    modifier = Modifier.weight(1f),
                )
                // 거리와 시간은 **자리를 맞춘다.** 줄마다 흔들리면 훑어 읽지 못한다
                Text(
                    row.amount,
                    style = MyFisTheme.type.body,
                    color = MyFisColor.TextPrimary,
                    textAlign = TextAlign.End,
                )
                Text(
                    row.duration,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextTertiary,
                )
            }
        }
    }
}

// ── 보여 주기용 값 ─────────────────────────────────────────────────────────

data class CardioWeek(
    val distance: String,
    /** 지난주 대비. 지난주가 없으면 `null` */
    val delta: String?,
)

data class CardioCount(val name: String, val free: Int)

data class CardioSessionRow(
    val date: String,
    val machine: String,
    val amount: String,
    val duration: String,
)

/** TODO: 서버가 붙으면 갈아끼운다 (C-01). `천국의 계단` 이름은 **지점마다 다르다** */
object CardioPlaceholder {
    const val branch = "MyFIS 강남점"

    val week = CardioWeek(distance = "12.4", delta = "지난주보다 +2.1km")

    val available = listOf(
        CardioCount("런닝머신", 4),
        CardioCount("천국의 계단", 2),
    )

    val recent = listOf(
        CardioSessionRow("8/26", "런닝머신", "3.2km", "24분"),
        CardioSessionRow("8/24", "천국의 계단", "1.1km", "18분"),
        CardioSessionRow("8/22", "런닝머신", "4.0km", "31분"),
    )
}
