package com.myfis.app.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MileageChip
import com.myfis.app.ui.components.MileageText
import com.myfis.app.ui.shell.HeaderIcon
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
 * 그 아래 **둥근 네모 아이콘 판 + `~하고` / `~받기`** 두 줄짜리 행 목록.
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
    Column(Modifier.fillMaxSize()) {
        BenefitHeader(onHistory = onHistory)

        LazyColumn(contentPadding = PaddingValues(bottom = MyFisSpacing.xxxl)) {
            item {
                InviteBanner(Modifier.padding(horizontal = MyFisSpacing.screenHorizontal))
            }
            item { SectionTitle("바로 받아요") }
            items(benefitActionPlaceholder) { ActionRow(it) { onAction(it) } }
        }
    }
}

/**
 * **아이콘 줄이다** — 다른 탭 헤더(§6.9)와 같은 골격.
 *
 * 글자 제목을 달지 않는다. 탭 화면에 제목을 두는 건 우리 규칙이 아니고,
 * **마일리지 칩이 이미 "여기는 P를 모으는 곳"이라고 말한다** (스토어 띠 §6.12 와 같은 칩).
 */
@Composable
private fun BenefitHeader(onHistory: () -> Unit, modifier: Modifier = Modifier) {
    val chipInteraction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp) // 헤더 높이 (§6.9) — 스토어 헤더와 같은 값
            // 아이콘의 터치 영역이 화면 여백만큼 튀어나오므로 그만큼 당겨 준다 (§6.9)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        MileageChip(
            balance = benefitBalancePlaceholder,
            modifier = Modifier
                .padding(start = MyFisSpacing.sm)
                .tapWithHaptics(chipInteraction, onHistory),
        )
        Spacer(Modifier.weight(1f))
        HeaderIcon(R.drawable.ic_header_history, "적립 내역", onHistory)
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
 * 적립 경로 한 줄 — 둥근 네모 아이콘 판 + `~하고` / `~받기`.
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
        // 색은 **갈래**를 말한다 (§3.1 카테고리 팔레트) — **아이콘에만** 칠한다.
        // 판은 색 없는 중립이다 — 열두 줄이 색 판이면 목록이 색 견본집처럼 읽힌다
        Box(
            modifier = Modifier
                .size(MyFisSize.listRowMin)
                .background(
                    if (dimmed) MyFisColor.Surface1 else MyFisColor.Surface2,
                    MyFisRadius.tile,
                )
                // 테두리 한 줄이 판을 **타일**로 만든다 — 없으면 배경에 녹는다
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.tile),
            contentAlignment = Alignment.Center,
        ) {
            // 행 아이콘은 **전부 원색 그림**이라 tint 를 걸지 않는다 — 한 색으로 누르면 실루엣이 된다.
            // 받은 행에서는 색을 빼야 하는데 칠할 수가 없으니 **채도를 0 으로 내린다**
            Image(
                painter = painterResource(action.icon),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                modifier = Modifier
                    .size(28.dp)
                    .alpha(if (dimmed) 0.5f else 1f),
                colorFilter = if (dimmed) {
                    ColorFilter.colorMatrix(ColorMatrix().apply { setToSaturation(0f) })
                } else {
                    null
                },
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
 * 적립 활동 종류 — 목록에서 **색으로 구분한다** (§3.1 카테고리 팔레트).
 *
 * **행마다 색이 다르다.** 아홉 줄이 같은 회색이면 목록이 덩어리로 보이고,
 * 색을 몇 개로 묶으면 "왜 이 둘만 같은 색이지"를 먼저 묻게 된다.
 */
enum class BenefitKind {
    ATTEND, ROUTINE, CARDIO, STRETCH, WATER, DICE, LUCK, SCRATCH, QUIZ, TOUCH, SNS, WEIGHT, DIET,
    ;

    val color: Color
        get() = when (this) {
            ATTEND -> MyFisColor.CategoryGold
            ROUTINE -> MyFisColor.CategoryLime
            CARDIO -> MyFisColor.CategoryBlue
            STRETCH -> MyFisColor.CategoryViolet
            WATER -> MyFisColor.CategoryCyan
            DICE -> MyFisColor.CategoryOrange
            LUCK -> MyFisColor.CategoryTeal
            SCRATCH -> MyFisColor.CategoryFuchsia
            QUIZ -> MyFisColor.CategoryIndigo
            TOUCH -> MyFisColor.CategoryGreen
            SNS -> MyFisColor.CategoryPink
            WEIGHT -> MyFisColor.CategoryCoral
            // 아홉 번째만 무채색이다 — 색을 하나 더 만드는 대신 **이미 받은 자리**에 중립색을 뒀다.
            // 어차피 받은 행은 톤을 낮춰 회색으로 그린다
            DIET -> MyFisColor.CategoryGray
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
    /**
     * 활동 랜딩(§6.25)에서 쓸 글리프. `null` 이면 행과 같은 것을 쓴다.
     * 행만 원색으로 갈아 끼울 때 쓴다 — 랜딩은 아직 두 톤 벌이다
     */
    val introIcon: Int? = null,
) {
    /** 랜딩에 띄울 글리프 */
    val glyph: Int get() = introIcon ?: icon

    /** 그 글리프를 **자기 색 그대로** 그릴지. 두 톤 벌로 되돌린 자리는 다시 칠해야 한다 */
    val glyphKeepsColor: Boolean get() = introIcon == null
}

// TODO(서버): 적립 단가·상태는 서버가 준다 (SPEC §8). 하드코딩하지 않는다
const val benefitBalancePlaceholder = 1_240
const val benefitEarnedThisMonthPlaceholder = 320

val benefitActionPlaceholder = listOf(
    BenefitAction(
        1, BenefitKind.ATTEND, R.drawable.ic_benefit_attend_color, "오늘 출석 도장 찍기", "+50 P 받기",
        introIcon = R.drawable.ic_benefit_attend,
    ),
    BenefitAction(
        2, BenefitKind.ROUTINE, R.drawable.ic_benefit_routine_color, "오늘 루틴 끝내기", "+80 P 받기",
        introIcon = R.drawable.ic_benefit_routine,
    ),
    BenefitAction(
        3, BenefitKind.CARDIO, R.drawable.ic_benefit_cardio_color, "유산소 10분 채우기", "10분마다 +10 P",
        introIcon = R.drawable.ic_benefit_cardio,
    ),
    BenefitAction(
        4, BenefitKind.STRETCH, R.drawable.ic_benefit_stretch_color, "AI가 고른 3동작 따라 하기", "+20 P 받기",
        introIcon = R.drawable.ic_benefit_stretch,
    ),
    BenefitAction(
        5, BenefitKind.WATER, R.drawable.ic_benefit_water_color, "물 8잔 채우기",
        "8잔 채우면 +50 P", introIcon = R.drawable.ic_benefit_water,
    ),
    // 랜딩에도 이 그림을 그대로 쓴다 — 주사위는 두 톤 벌이 아예 없다
    BenefitAction(
        6, BenefitKind.DICE, R.drawable.ic_benefit_dice_color, "주사위 굴리기", "나온 눈만큼 P 받기",
    ),
    BenefitAction(
        7, BenefitKind.LUCK, R.drawable.ic_benefit_luck_color, "뽑기 돌리기",
        "랜덤 P 받기", badge = "이벤트", introIcon = R.drawable.ic_benefit_luck,
    ),
    // 주사위 · 뽑기 바로 뒤에 둔다 — **운으로 받는 셋**이 한 덩어리로 읽힌다
    BenefitAction(
        13, BenefitKind.SCRATCH, R.drawable.ic_benefit_scratch_color, "은박 카드 긁기", "숨은 P 받기",
    ),
    BenefitAction(8, BenefitKind.QUIZ, R.drawable.ic_benefit_quiz, "AI가 생각하는 퀴즈 풀기", "+30 P 받기"),
    BenefitAction(
        9, BenefitKind.TOUCH, R.drawable.ic_benefit_touch_color, "함께 마일리지 받기",
        "+10 P 받기", badge = "신규", introIcon = R.drawable.ic_benefit_touch,
    ),
    BenefitAction(
        10, BenefitKind.SNS, R.drawable.ic_benefit_sns, "인스타에 인증샷 올리기",
        "+100 P 받기", badge = "인기",
    ),
    BenefitAction(
        11, BenefitKind.WEIGHT, R.drawable.ic_benefit_scale_color, "오늘 체중 재기", "+20 P 받기",
        introIcon = R.drawable.ic_benefit_scale,
    ),
    BenefitAction(
        12, BenefitKind.DIET, R.drawable.ic_benefit_diet_color, "먹은 것 사진 찍기",
        "+20 P 받기", done = true, introIcon = R.drawable.ic_benefit_diet,
    ),
)
