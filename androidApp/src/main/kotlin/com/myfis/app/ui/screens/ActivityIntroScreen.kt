package com.myfis.app.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
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
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
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
import kotlinx.coroutines.launch

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
fun ActivityIntroScreen(action: BenefitAction, onClose: () -> Unit) {
    val intro = action.kind.intro
    // 연출은 **이 화면 안에서** 끝난다 — 뽑기·사다리는 결과까지 여기서 보여준다 (§6.25)
    var stage by remember { mutableStateOf(ActivityStage.IDLE) }
    val progress = remember { Animatable(0f) }
    val scope = rememberCoroutineScope()

    // 대기 → 재생 → 결과. **연출이 끝나야 버튼이 다시 산다**
    val onButton = {
        when (stage) {
            ActivityStage.IDLE -> if (!intro.stagecraft) {
                // TODO: 연출이 없는 활동은 화면(P-05~P-13)이 붙으면 연결한다
                onClose()
            } else {
                stage = ActivityStage.PLAYING
                scope.launch {
                    progress.animateTo(1f, tween(intro.durationMs, easing = LinearEasing))
                    stage = ActivityStage.RESULT
                }
                Unit
            }
            ActivityStage.PLAYING -> Unit
            // TODO(서버): 여기서 적립을 올린다
            ActivityStage.RESULT -> onClose()
        }
    }
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(
            title = action.kind.intro.kicker,
            onBack = onClose,
            backIcon = R.drawable.ic_header_close,
            backDescription = "닫기",
        )

        Column(
            Modifier
                .weight(1f)
                // **폭을 꽉 채워야 가운데 정렬이 화면 기준이 된다.**
                // 없으면 내용 폭만큼만 잡혀 통째로 왼쪽에 붙는다 (2026-08-26 확인)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.xxxl, bottom = MyFisSpacing.xxxl),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            // 작은 라벨이 제목 위에 붙어야 머리가 두 단으로 잡힌다 (레퍼런스와 같은 구성)
            Text(
                action.kind.intro.label,
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
                action.kind.intro.period,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = MyFisSpacing.md),
            )

            Illustration(
                action = action,
                stage = stage,
                progress = progress.value,
                modifier = Modifier.padding(top = MyFisSpacing.giant),
            )

            HintBubble(
                text = action.kind.intro.hint,
                color = action.kind.color,
                modifier = Modifier.padding(top = MyFisSpacing.giant),
            )
        }

        MyFisPrimaryButton(
            text = when (stage) {
                ActivityStage.IDLE -> intro.cta
                ActivityStage.PLAYING -> intro.playing
                ActivityStage.RESULT -> "${intro.reward} 받기"
            },
            onClick = onButton,
            enabled = stage != ActivityStage.PLAYING,
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
private fun Illustration(
    action: BenefitAction,
    stage: ActivityStage,
    progress: Float,
    modifier: Modifier = Modifier,
) {
    val color = action.kind.color
    val style = action.kind.intro.art
    val transition = rememberInfiniteTransition(label = "활동 그림")
    val phase by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(style.duration, easing = FastOutSlowInEasing),
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

        // 뒤를 흐르는 원판들. 활동마다 개수·자리·방향이 다르다
        style.discs.forEach { disc ->
            Box(
                Modifier
                    .offset(x = disc.x.dp, y = (disc.y + disc.dy * phase).dp)
                    .size(disc.size.dp)
                    .background(color.copy(alpha = disc.alpha), MyFisRadius.full),
            )
        }

        when {
            stage != ActivityStage.IDLE && action.kind == BenefitKind.LUCK ->
                LuckStage(color, progress, action.kind.intro.reward)
            stage != ActivityStage.IDLE && action.kind == BenefitKind.LADDER ->
                LadderStage(color, progress, action.kind.intro.reward)
            else -> Glyph(
            icon = action.glyph,
            // 원색 아이콘은 **자기 색 그대로** 띄운다 (brush = null). 칠하면 그림이 실루엣으로 뭉갠다
            brush = if (action.glyphKeepsColor) {
                null
            } else {
                Brush.verticalGradient(listOf(color, color.copy(alpha = 0.62f)))
            },
            modifier = Modifier
                .offset(y = (style.dy - 2 * style.dy * phase).dp)
                .graphicsLayer {
                    rotationZ = -style.rotation + 2 * style.rotation * phase
                    val s = 1f - style.pulse + 2 * style.pulse * phase
                    scaleX = s
                    scaleY = s
                },
            shadow = color.copy(alpha = 0.45f),
            )
        }
    }
}

/** 벡터를 **그라디언트로** 칠한다. `tint` 는 한 가지 색밖에 못 넣는다. `brush = null` 이면 원본 색 그대로 */
@Composable
private fun Glyph(icon: Int, brush: Brush?, shadow: Color, modifier: Modifier = Modifier) {
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
                    brush?.let { drawRect(it, blendMode = BlendMode.SrcIn) }
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

/**
 * 활동 한 벌의 **말과 움직임**. 활동마다 한 곳에 모아 둔다 —
 * 흩어 두면 뽑기는 들뜨고 체중은 담담해야 하는 **말투 차이**가 금세 뭉개진다.
 */
data class ActivityIntro(
    /** 헤더 가운데 한 단어 */
    val kicker: String,
    /** 제목 위 작은 라벨 */
    val label: String,
    /** 제목 밑 조건 한 줄 */
    val period: String,
    /** 버튼 위 말풍선 — 누르고 싶게 만드는 한마디 */
    val hint: String,
    /** 버튼 글자 — **다음에 일어날 일** (§6.1) */
    val cta: String,
    /** 그림이 움직이는 결 (§6.25) */
    val art: ActivityArtStyle = ActivityArtStyle(),
    /** 재생 중 버튼 글자 */
    val playing: String = "잠깐만요…",
    // TODO(서버): 결과는 서버가 정한다. 지금은 자리값
    val reward: String = "+20 P",
    /** 연출이 있는 활동인가 — 없으면 버튼이 그냥 닫는다 */
    val stagecraft: Boolean = false,
    /** 연출 길이(ms) */
    val durationMs: Int = 2200,
)

/** 그림의 결. **활동마다 다르게 움직인다** — 다 같은 박자로 뜨면 색만 바뀐 같은 화면이 된다 */
data class ActivityArtStyle(
    /** 한 번 왕복하는 시간(ms). 짧을수록 들뜬 느낌 */
    val duration: Int = 2600,
    /** 위아래로 뜨는 폭 */
    val dy: Float = 10f,
    /** 기울어지는 각도 */
    val rotation: Float = 4f,
    /** 커졌다 작아지는 폭 (불꽃·통통 튀는 것에 쓴다) */
    val pulse: Float = 0f,
    /** 뒤를 흐르는 원판들 */
    val discs: List<Disc> = listOf(
        Disc(-96f, -28f, 86f, 0.16f, -24f),
        Disc(92f, 30f, 54f, 0.10f, 26f),
    ),
) {
    /** 움직이는 방향과 폭은 **글리프와 반대로** 둬야 두 겹으로 보인다 */
    data class Disc(
        val x: Float,
        val y: Float,
        val size: Float,
        val alpha: Float,
        val dy: Float,
    )
}

/**
 * 활동별 말과 움직임. 말투를 일부러 다르게 썼다 —
 * 뽑기·사다리는 들뜨게, 출석·체중은 담담하게, 스트레칭은 부드럽게.
 */
val BenefitKind.intro: ActivityIntro
    get() = when (this) {
        BenefitKind.ATTEND -> ActivityIntro(
            "출석", "매일 첫 걸음", "하루 한 번", "지점에 닿으면 바로 눌러요", "출석 체크하기",
            ActivityArtStyle(
                duration = 1800, dy = 16f, rotation = 2f,
                discs = listOf(ActivityArtStyle.Disc(0f, 96f, 120f, 0.12f, 8f)),
            ),
        )
        BenefitKind.ROUTINE -> ActivityIntro(
            "루틴", "오늘 몫은 오늘", "루틴을 끝까지", "5개 중 2개 남았어요", "웨이트 하러 가기",
            ActivityArtStyle(
                duration = 2200, dy = 8f, rotation = 12f,
                discs = listOf(
                    ActivityArtStyle.Disc(-104f, 0f, 72f, 0.14f, 18f),
                    ActivityArtStyle.Disc(104f, 0f, 72f, 0.14f, -18f),
                ),
            ),
        )
        BenefitKind.CARDIO -> ActivityIntro(
            "유산소", "태운 만큼 쌓여요", "10분마다", "20분만 뛰어도 +20 P", "유산소 하러 가기",
            ActivityArtStyle(
                duration = 1400, dy = 6f, rotation = 2f, pulse = 0.1f,
                discs = listOf(
                    ActivityArtStyle.Disc(-70f, 70f, 46f, 0.12f, -40f),
                    ActivityArtStyle.Disc(78f, 88f, 34f, 0.10f, -52f),
                ),
            ),
        )
        BenefitKind.STRETCH -> ActivityIntro(
            "스트레칭", "3분이면 끝나요", "하루 한 번", "AI가 오늘 고른 3동작", "스트레칭 시작",
            ActivityArtStyle(
                duration = 3200, dy = 4f, rotation = 9f,
                discs = listOf(ActivityArtStyle.Disc(0f, 0f, 190f, 0.08f, 0f)),
            ),
        )
        BenefitKind.WATER -> ActivityIntro(
            "물 마시기", "하루 여덟 잔", "오늘 안에", "지금 세 잔째", "한 잔 마셨어요",
            ActivityArtStyle(
                duration = 1600, dy = 18f, rotation = 0f,
                discs = listOf(ActivityArtStyle.Disc(0f, 86f, 150f, 0.12f, -6f)),
            ),
        )
        BenefitKind.LADDER -> ActivityIntro(
            "사다리", "오늘의 사다리", "하루 한 번", "꽝은 없어요. 최소 10 P", "사다리 타기",
            ActivityArtStyle(
                duration = 2400, dy = 20f, rotation = 0f,
                discs = listOf(
                    ActivityArtStyle.Disc(-88f, -40f, 60f, 0.14f, 34f),
                    ActivityArtStyle.Disc(88f, 40f, 60f, 0.12f, -34f),
                ),
            ),
            playing = "내려가는 중…", reward = "+80 P", stagecraft = true, durationMs = 2600,
        )
        BenefitKind.LUCK -> ActivityIntro(
            "뽑기", "오늘의 운을 시험할 시간", "하루 한 번", "오늘의 행운은 최대 500 P", "뽑기 돌리기",
            ActivityArtStyle(duration = 2600, dy = 10f, rotation = 16f),
            playing = "돌리는 중…", reward = "+320 P", stagecraft = true, durationMs = 2200,
        )
        BenefitKind.QUIZ -> ActivityIntro(
            "퀴즈", "AI가 낸 오늘 문제", "하루 한 문제", "어제는 62%가 맞혔어요", "퀴즈 풀기",
            ActivityArtStyle(
                duration = 1900, dy = 14f, rotation = 3f, pulse = 0.06f,
                discs = listOf(
                    ActivityArtStyle.Disc(-84f, -56f, 40f, 0.14f, -14f),
                    ActivityArtStyle.Disc(96f, -20f, 28f, 0.12f, 16f),
                    ActivityArtStyle.Disc(60f, 76f, 52f, 0.10f, 20f),
                ),
            ),
        )
        BenefitKind.TOUCH -> ActivityIntro(
            "함께", "같이 운동하는 사람들", "같은 지점에 있을 때", "지금 강남점에 12명 있어요",
            "옆 사람 찾기",
            ActivityArtStyle(
                duration = 2000, dy = 6f, rotation = 3f,
                discs = listOf(
                    ActivityArtStyle.Disc(-110f, 10f, 64f, 0.14f, 0f),
                    ActivityArtStyle.Disc(110f, 10f, 64f, 0.14f, 0f),
                ),
            ),
        )
        BenefitKind.SNS -> ActivityIntro(
            "자랑", "오늘의 한 컷", "하루 한 번", "#MyFIS 를 달면 바로 인증돼요", "사진 고르기",
            ActivityArtStyle(
                duration = 2800, dy = 16f, rotation = 2f,
                discs = listOf(
                    ActivityArtStyle.Disc(-76f, 84f, 52f, 0.13f, -56f),
                    ActivityArtStyle.Disc(82f, 66f, 34f, 0.10f, -44f),
                ),
            ),
        )
        BenefitKind.WEIGHT -> ActivityIntro(
            "기록", "매일 남기는 한 줄", "오늘 하루", "어제보다 -0.3 kg", "체중 기록하기",
            ActivityArtStyle(
                duration = 3400, dy = 6f, rotation = 2f,
                discs = listOf(ActivityArtStyle.Disc(0f, 92f, 140f, 0.10f, 0f)),
            ),
        )
        BenefitKind.DIET -> ActivityIntro(
            "식단", "먹은 걸 남기면", "한 끼에 한 번", "AI가 칼로리까지 읽어줘요", "식단 찍기",
            ActivityArtStyle(
                duration = 3000, dy = 8f, rotation = 6f,
                discs = listOf(
                    ActivityArtStyle.Disc(-92f, 46f, 58f, 0.12f, -18f),
                    ActivityArtStyle.Disc(88f, -46f, 44f, 0.10f, 18f),
                ),
            ),
        )
    }
