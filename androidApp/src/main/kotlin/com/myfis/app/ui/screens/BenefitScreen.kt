package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MileageText
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md P-01 혜택 홈 (DESIGN.md §6.24).
 *
 * 레퍼런스는 **카카오뱅크 혜택 탭**이다 — 제목 + 요약이 한 줄, 배너 하나,
 * 그 아래 **동그란 아이콘 + `~하고` / `~받기`** 두 줄짜리 행 목록.
 * **구조만 가져오고 색은 우리 것을 쓴다** (§3.2) — 원본은 뱃지마다 색이 다르지만
 * 우리는 다크 + 라임 하나다.
 *
 * 이 탭이 답하는 질문은 하나 — **"오늘 더 받을 수 있는 게 뭐지"**.
 * 잔액을 자랑하는 화면이 아니다 (그건 스토어 §6.12 가 한다).
 */
@Composable
fun BenefitScreen(
    onHistory: () -> Unit = {},
    onAction: (BenefitAction) -> Unit = {},
) {
    val todo = remember { benefitActionPlaceholder.filter { !it.done } }
    val done = remember { benefitActionPlaceholder.filter { it.done } }

    Column(Modifier.fillMaxSize()) {
        BenefitHeader(onHistory = onHistory)

        LazyColumn(contentPadding = PaddingValues(bottom = MyFisSpacing.xxxl)) {
            item {
                InviteBanner(Modifier.padding(horizontal = MyFisSpacing.screenHorizontal))
            }
            item { SectionTitle("바로 받아요") }
            items(todo) { ActionRow(it) { onAction(it) } }
            if (done.isNotEmpty()) {
                item { SectionTitle("오늘 받았어요") }
                items(done) { ActionRow(it) { onAction(it) } }
            }
        }
    }
}

/**
 * 제목 + 요약 두 개. **탭 화면인데 제목을 다는 유일한 자리다** —
 * 홈·스토어와 달리 헤더에 넣을 아이콘이 없고, 요약 숫자가 제목 역할을 대신하지도 못한다.
 */
@Composable
private fun BenefitHeader(onHistory: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp) // 헤더 높이 (§6.9) — 스토어 헤더와 같은 값
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("혜택", style = MyFisTheme.type.titleLg, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))

        Row(
            modifier = Modifier.tapWithHaptics(interaction, onHistory),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    painter = painterResource(R.drawable.ic_mileage_fill),
                    contentDescription = null, // 옆 숫자가 이름 역할을 한다
                    tint = MyFisColor.Accent,
                    modifier = Modifier.size(20.dp),
                )
                MileageText(
                    benefitBalancePlaceholder,
                    style = MyFisTheme.type.titleSm,
                    modifier = Modifier.padding(start = MyFisSpacing.xs),
                )
            }

            // 두 숫자를 가르는 선. 같은 무게로 나란히 두면 어느 쪽이 잔액인지 안 갈린다
            Box(
                Modifier
                    .width(1.dp)
                    .height(14.dp)
                    .background(MyFisColor.BorderSubtle),
            )

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("이번 달 ", style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
                Text(
                    "+%,d P".format(benefitEarnedThisMonthPlaceholder),
                    style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                    color = MyFisColor.TextSecondary,
                )
            }
        }
    }
}

@Composable
private fun SectionTitle(title: String) {
    Text(
        title,
        style = MyFisTheme.type.titleMd,
        color = MyFisColor.TextPrimary,
        modifier = Modifier.padding(
            start = MyFisSpacing.screenHorizontal,
            end = MyFisSpacing.screenHorizontal,
            top = MyFisSpacing.sectionGap,
            bottom = MyFisSpacing.sm,
        ),
    )
}

/**
 * 적립 경로 한 줄 — 동그란 아이콘 + `~하고` / `~받기`.
 *
 * **제목이 행동, 부제가 보상이다.** 반대로 두면 다 똑같이 "P 받기"로 시작해 구분이 안 된다.
 */
@Composable
private fun ActionRow(action: BenefitAction, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val dimmed = action.done

    Row(
        modifier = Modifier
            .fillMaxWidth()
            // 누름 축소는 아이콘에만 (§6.7). 행이 통째로 움찔거리면 목록이 흔들려 보인다
            .tapWithHaptics(interaction, onClick)
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.md,
            ),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        // 색은 **갈래**를 말한다 (§3.1 카테고리 팔레트) — 아이콘에만 칠하고
        // 배경은 같은 색 16%. 받은 행은 색을 뺀다 (지난 일이라 갈래를 알 필요가 없다)
        Box(
            modifier = Modifier
                .size(MyFisSize.listRowMin)
                .background(
                    if (dimmed) MyFisColor.Surface2 else action.kind.color.copy(alpha = 0.16f),
                    CircleShape,
                ),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(action.icon),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                tint = if (dimmed) MyFisColor.TextTertiary else action.kind.color,
                modifier = Modifier.size(26.dp),
            )
        }

        Column {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                Text(
                    action.title,
                    style = MyFisTheme.type.titleSm,
                    color = if (dimmed) MyFisColor.TextTertiary else MyFisColor.TextPrimary,
                )
                if (action.badge != null && !dimmed) Badge(action.badge)
            }
            Text(
                if (dimmed) "오늘 받았어요" else action.reward,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(top = 2.dp),
            )
        }
    }
}

/**
 * 행 뱃지 — **글자만 다르고 색은 하나다** (§3.2).
 * 레퍼런스는 노랑·빨강·파랑을 섞지만, 색이 셋이면 목록이 알림함처럼 종류별 색 목록으로 읽힌다.
 */
@Composable
private fun Badge(text: String) {
    Text(
        text,
        style = MyFisTheme.type.caption,
        color = MyFisColor.TextSecondary,
        modifier = Modifier
            .background(MyFisColor.Surface3, MyFisRadius.full)
            .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
    )
}

/** 배너 — **마일리지가 늘어나는 유일한 '내가 하는' 길**이라 맨 위에 둔다 (S-08 과 같은 판단) */
@Composable
private fun InviteBanner(modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    // TODO: 초대 링크 공유가 붙으면 연결한다
    Row(
        modifier = modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface1, MyFisRadius.lg)
            .tapWithHaptics(interaction) {}
            .padding(MyFisSpacing.cardPadding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(Modifier.weight(1f)) {
            Text("친구를 부르면", style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
            Text(
                "둘 다 1,000 P",
                style = MyFisTheme.type.titleMd,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.padding(top = 2.dp),
            )
        }
        Icon(
            painter = painterResource(R.drawable.ic_mileage_fill),
            contentDescription = null,
            tint = MyFisColor.Surface3,
            modifier = Modifier.size(44.dp),
        )
    }
}

/**
 * 적립 활동의 **갈래** — 목록에서 색으로 구분한다 (§3.1 카테고리 팔레트).
 *
 * 행마다 색을 하나씩 새로 고르지 않는다. 갈래가 같으면 색도 같아야
 * 색이 "종류"를 뜻하는 게 되지, 그냥 알록달록한 목록이 되지 않는다.
 */
enum class BenefitKind {
    /** 몸 쓰는 것 — 루틴 · 스트레칭 */
    WORKOUT,

    /** 유산소 */
    CARDIO,

    /** 지점에 오는 것 — 출석 */
    VISIT,

    /** 이벤트 — 도장판 */
    EVENT,

    /** 사람과 엮이는 것 — 옆 사람 터치 · SNS 자랑 */
    SOCIAL,

    /** 기록 — 체중 · 식단 */
    RECORD,
    ;

    val color: Color
        get() = when (this) {
            WORKOUT -> MyFisColor.CategoryLime
            CARDIO -> MyFisColor.CategoryBlue
            VISIT -> MyFisColor.CategoryGold
            EVENT -> MyFisColor.CategoryViolet
            SOCIAL -> MyFisColor.CategoryGreen
            RECORD -> MyFisColor.CategoryCoral
        }
}

/** 적립 경로 한 줄 (SPEC P-01) */
data class BenefitAction(
    val id: Int,
    val kind: BenefitKind,
    val icon: Int,
    /** 행동 — `출석하고` */
    val title: String,
    /** 보상 — `+50 P 받기` */
    val reward: String,
    /** `이벤트` · `신규` · `인기`. 없으면 null */
    val badge: String? = null,
    /** 오늘 이미 받았다 */
    val done: Boolean = false,
)

// TODO(서버): 적립 단가·상태는 서버가 준다 (SPEC §8). 하드코딩하지 않는다
const val benefitBalancePlaceholder = 1_240
const val benefitEarnedThisMonthPlaceholder = 320

val benefitActionPlaceholder = listOf(
    BenefitAction(1, BenefitKind.VISIT, R.drawable.ic_quest_attend, "출석하고", "+50 P 받기"),
    BenefitAction(2, BenefitKind.WORKOUT, R.drawable.ic_tab_weight, "루틴 끝내고", "+80 P 받기"),
    BenefitAction(3, BenefitKind.CARDIO, R.drawable.ic_tab_cardio, "유산소 하고", "10분마다 +10 P"),
    BenefitAction(4, BenefitKind.WORKOUT, R.drawable.ic_quest_stretch, "스트레칭하고", "+20 P 받기"),
    BenefitAction(
        5, BenefitKind.EVENT, R.drawable.ic_quest_board, "도장 찍고",
        "7일 채우면 +200 P", badge = "이벤트",
    ),
    BenefitAction(
        6, BenefitKind.SOCIAL, R.drawable.ic_tab_group, "옆 사람 터치하고",
        "+10 P 받기", badge = "신규",
    ),
    BenefitAction(
        7, BenefitKind.SOCIAL, R.drawable.ic_quest_upload, "인스타에 올리고",
        "+100 P 받기", badge = "인기",
    ),
    BenefitAction(8, BenefitKind.RECORD, R.drawable.ic_quest_scale, "체중 재고", "+20 P 받기"),
    BenefitAction(
        9, BenefitKind.RECORD, R.drawable.ic_quest_camera, "식단 찍고",
        "+20 P 받기", done = true,
    ),
)
