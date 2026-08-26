package com.myfis.app.ui.screens

import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.BlendMode
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.CompositingStrategy
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 적립 활동에 들어가기 전 **랜딩** (DESIGN.md §6.25).
 *
 * 레퍼런스는 **카카오뱅크 이벤트 랜딩**이다 — 작은 라벨 · 두 줄짜리 큰 제목 · 기간 ·
 * 큰 그림 · 말풍선 한 줄 · 하단 버튼. **구조만 가져오고 색은 우리 것을 쓴다** (§3.2).
 *
 * **활동마다 화면을 따로 만들지 않는다.** 뽑기든 사다리든 여기 들어와서 버튼을 누르면 시작한다 —
 * 그래야 활동이 늘어나도 들어가는 길이 하나로 남는다.
 */
@Composable
fun ActivityIntroScreen(
    action: BenefitAction,
    onClose: () -> Unit,
    // TODO: 활동 화면이 붙으면 연결한다 (P-05 ~ P-13)
    onStart: () -> Unit = onClose,
) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(
            title = action.introKicker,
            onBack = onClose,
            backIcon = R.drawable.ic_header_close,
            backDescription = "닫기",
        )

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.xxxl, bottom = MyFisSpacing.xxxl),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // 작은 라벨이 제목 위에 붙어야 머리가 두 단으로 잡힌다 (레퍼런스와 같은 구성)
            Text(
                action.introLabel,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                textAlign = TextAlign.Center,
            )

            // 두 줄짜리 큰 제목 — 목록의 `~하고` / `~받기` 를 그대로 편 것이다.
            // 목록에서 누른 문장이 그대로 커지므로 어디로 왔는지 다시 읽을 필요가 없다
            Text(
                "${action.title}\n${action.reward}",
                style = MyFisTheme.type.display,
                color = MyFisColor.TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = MyFisSpacing.sm),
            )

            Text(
                action.introPeriod,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = MyFisSpacing.md),
            )

            Illustration(action, Modifier.padding(top = MyFisSpacing.giant))

            HintBubble(
                text = action.introHint,
                color = action.kind.color,
                modifier = Modifier.padding(top = MyFisSpacing.giant),
            )
        }

        MyFisPrimaryButton(
            text = action.introCta,
            onClick = onStart,
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.xxxl),
        )
    }
}

/**
 * 활동 그림 — **큰 글리프 하나와 그 뒤를 떠다니는 원판들.**
 *
 * 아이콘을 그냥 크게 키우면 검정 위에 납작하게 붙어 그림처럼 안 보인다 (2026-08-26 지적).
 * 세 가지로 살린다 — **그라디언트**로 위아래 색을 다르게, **그림자**로 띄우고,
 * 뒤에 원판을 **다른 박자로** 흘린다.
 *
 * 색 원판 위에 아이콘을 얹는 안은 버렸다 — 뽑기 캡슐처럼 **동그란 아이콘이 구멍처럼** 보인다 (확인함).
 * 움직임은 끊기지 않고 계속이다 (동작 줄이기가 켜져 있으면 시스템이 알아서 멈춘다).
 */
@Composable
private fun Illustration(action: BenefitAction, modifier: Modifier = Modifier) {
    val color = action.kind.color
    val transition = rememberInfiniteTransition(label = "활동 그림")
    val phase by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(2600, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "떠다님",
    )

    Box(modifier.height(260.dp), contentAlignment = Alignment.Center) {
        // 빛 — 검정 위에 글리프만 두면 붕 떠 보인다 (§6.25)
        Box(
            Modifier
                .size(320.dp)
                .graphicsLayer {
                    val s = 0.92f + 0.14f * phase
                    scaleX = s
                    scaleY = s
                }
                .background(
                    Brush.radialGradient(
                        colors = listOf(color.copy(alpha = 0.26f), Color.Transparent),
                    ),
                    MyFisRadius.full,
                ),
        )

        // 뒤를 흐르는 원판 둘. 서로 **반대로** 움직여야 한 덩어리로 안 보인다
        Box(
            Modifier
                .offset(x = (-96).dp, y = (-28 - 24 * phase).dp)
                .size(86.dp)
                .background(color.copy(alpha = 0.16f), MyFisRadius.full),
        )
        Box(
            Modifier
                .offset(x = 92.dp, y = (30 + 26 * phase).dp)
                .size(54.dp)
                .background(color.copy(alpha = 0.10f), MyFisRadius.full),
        )

        Glyph(
            icon = action.icon,
            brush = Brush.verticalGradient(listOf(color, color.copy(alpha = 0.62f))),
            modifier = Modifier
                .offset(y = (10 - 20 * phase).dp)
                .graphicsLayer { rotationZ = -4f + 8f * phase },
            shadow = color.copy(alpha = 0.45f),
        )
    }
}

/** 벡터를 **그라디언트로** 칠한다. `tint` 는 한 가지 색밖에 못 넣는다 */
@Composable
private fun Glyph(icon: Int, brush: Brush, shadow: Color, modifier: Modifier = Modifier) {
    Box(modifier, contentAlignment = Alignment.Center) {
        // 그림자 — 같은 글리프를 한 벌 더 깔고 흐린다 (API 31 미만에서는 그냥 안 흐려진다)
        Image(
            painter = painterResource(icon),
            contentDescription = null,
            colorFilter = ColorFilter.tint(shadow),
            modifier = Modifier
                .size(148.dp)
                .offset(y = 14.dp)
                .blur(22.dp),
        )
        Image(
            painter = painterResource(icon),
            contentDescription = null, // 위 제목이 이름 역할을 한다
            modifier = Modifier
                .size(148.dp)
                // 오프스크린으로 그려야 SrcIn 이 글리프 알파에만 걸린다
                .graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)
                .drawWithContent {
                    drawContent()
                    drawRect(brush, blendMode = BlendMode.SrcIn)
                },
        )
    }
}

/**
 * 말풍선 한 줄 — 버튼 바로 위에서 **누르고 싶게 만드는** 한마디.
 * 꼬리가 버튼을 가리키므로 아래를 향한다
 */
@Composable
private fun HintBubble(text: String, color: Color, modifier: Modifier = Modifier) {
    Column(modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text,
            style = MyFisTheme.type.bodySm,
            color = color,
            modifier = Modifier
                .background(color.copy(alpha = 0.16f), MyFisRadius.full)
                .padding(horizontal = MyFisSpacing.lg, vertical = MyFisSpacing.md),
        )
        Canvas(Modifier.size(width = 14.dp, height = 7.dp)) {
            val path = Path().apply {
                moveTo(0f, 0f)
                lineTo(size.width, 0f)
                lineTo(size.width / 2, size.height)
                close()
            }
            drawPath(path, color.copy(alpha = 0.16f))
        }
    }
}

/** 헤더 가운데 — 활동이 아니라 **갈래**를 적는다 (제목은 본문이 크게 맡는다) */
val BenefitAction.introKicker: String
    get() = when (kind) {
        BenefitKind.STAMP, BenefitKind.LADDER, BenefitKind.LUCK, BenefitKind.QUIZ -> "이벤트"
        BenefitKind.TOUCH, BenefitKind.SNS -> "함께 하기"
        BenefitKind.ATTEND, BenefitKind.ROUTINE, BenefitKind.CARDIO, BenefitKind.STRETCH -> "운동"
        BenefitKind.WEIGHT, BenefitKind.DIET -> "기록"
    }

/** 제목 위 작은 라벨 — 무슨 판에서 벌어지는 일인지 */
val BenefitAction.introLabel: String
    get() = when (kind) {
        BenefitKind.STAMP, BenefitKind.LADDER, BenefitKind.LUCK, BenefitKind.QUIZ ->
            "마일리지 미니 이벤트"
        BenefitKind.TOUCH, BenefitKind.SNS -> "같이 하면 더 받는 적립"
        BenefitKind.ATTEND, BenefitKind.ROUTINE, BenefitKind.CARDIO, BenefitKind.STRETCH ->
            "운동하고 받는 마일리지"
        BenefitKind.WEIGHT, BenefitKind.DIET -> "매일 남기는 기록"
    }

// TODO(서버): 기간·조건은 서버가 준다
val BenefitAction.introPeriod: String
    get() = when (kind) {
        BenefitKind.STAMP -> "이번 주 7일 채우기"
        BenefitKind.LADDER, BenefitKind.LUCK, BenefitKind.QUIZ -> "하루 한 번"
        BenefitKind.TOUCH -> "같은 지점에 있을 때"
        else -> "오늘 하루"
    }

val BenefitAction.introHint: String
    get() = when (kind) {
        BenefitKind.STAMP -> "이번 주 4일째 채우는 중"
        BenefitKind.LADDER -> "오늘의 사다리, 최대 200 P"
        BenefitKind.LUCK -> "오늘의 행운은 최대 500 P"
        BenefitKind.QUIZ -> "AI가 오늘 낸 문제 한 개"
        BenefitKind.TOUCH -> "지금 강남점에 12명 있어요"
        BenefitKind.SNS -> "#MyFIS 로 올리면 인증돼요"
        else -> "오늘 아직 안 받았어요"
    }

/** 버튼 글자는 **다음에 일어날 일**을 적는다 (§6.1) */
val BenefitAction.introCta: String
    get() = when (kind) {
        BenefitKind.STAMP -> "도장 찍기"
        BenefitKind.LADDER -> "사다리 타기"
        BenefitKind.LUCK -> "뽑기 돌리기"
        BenefitKind.QUIZ -> "퀴즈 풀기"
        BenefitKind.TOUCH -> "옆 사람 찾기"
        BenefitKind.SNS -> "사진 고르기"
        BenefitKind.ATTEND -> "출석 체크하기"
        BenefitKind.ROUTINE -> "웨이트 하러 가기"
        BenefitKind.CARDIO -> "유산소 하러 가기"
        BenefitKind.STRETCH -> "스트레칭 시작"
        BenefitKind.WEIGHT -> "체중 기록하기"
        BenefitKind.DIET -> "식단 찍기"
    }
