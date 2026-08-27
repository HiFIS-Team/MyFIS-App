package com.myfis.app.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.CubicBezierEasing
import androidx.compose.animation.core.EaseIn
import androidx.compose.animation.core.EaseOut
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.random.Random

/**
 * P-11 **주사위 굴리기** — 하루 한 번 굴려서 나온 눈만큼 받는다.
 *
 * **진짜로 굴러야 한다** (사용자 지정, 2026-08-27). 숫자만 바뀌고 끝나면 뽑기와 구분이 안 된다 —
 * 던져서 뜨고, 구르고, 떨어져 멈춘다. 네 가지를 겹쳐 그 느낌을 만든다:
 *
 * | 겹 | 값 | 왜 |
 * |----|-----|-----|
 * | 회전 | **2D 로 세 바퀴** + 기울기 26° | 구르는 몸통 |
 * | 눈 | 무작위로 갈리다 **간격이 점점 벌어진다** | 회전이 느려지는 걸 눈이 따라간다 |
 * | 높이 | 올라갔다 내려온다 | 던진 것이지 돌린 것이 아니다 |
 * | 그림자 | 뜨면 **작고 옅어진다** | 높이를 바닥이 알려 준다 |
 *
 * ⚠️ **`rotationY` 로 한 바퀴를 돌리지 않는다.** 90°에서 몸통이 종잇장이 되어
 * 구르는 게 아니라 **카드가 뒤집히는** 것으로 읽힌다 (iOS 에서 확인함). 도는 건 `rotationZ` 로 하고,
 * 입체감은 90°에 닿지 않는 기울기(26°)로만 준다.
 *
 * 액센트는 **결과 숫자 + Primary 2곳**이다 (§3.2). 몸통은 갈래 색(`category.orange`) —
 * 목록에서 누른 주황이 그대로 커지는 것이라 어디서 왔는지 다시 읽을 필요가 없다.
 */
@Composable
fun DiceScreen(onClose: () -> Unit) {
    val scope = rememberCoroutineScope()
    val spin = remember { Animatable(0f) }
    val lift = remember { Animatable(0f) }
    val tilt = remember { Animatable(0f) }
    var face by remember { mutableIntStateOf(5) }
    var stage by remember { mutableStateOf<DiceStage>(DiceStage.Idle) }

    fun roll() {
        stage = DiceStage.Rolling
        // TODO(서버): 눈은 서버가 정한다 (SPEC §8). 클라이언트가 뽑으면 조작할 수 있다
        val pips = Random.nextInt(1, 7)

        // 세 바퀴를 끝에서 급히 죽인다. 딱 떨어지게 세우지 않는다 — 진짜 주사위는 조금 비뚤게 선다
        scope.launch {
            spin.animateTo(
                spin.value + 1080f + Random.nextInt(-11, 12),
                tween(1250, easing = CubicBezierEasing(0.08f, 0.62f, 0.16f, 1f)),
            )
        }
        // 던졌다가 떨어진다. 올라갈 때보다 내려올 때가 조금 길다
        scope.launch {
            lift.animateTo(1f, tween(420, easing = EaseOut))
            lift.animateTo(0f, tween(620, easing = EaseIn))
        }
        scope.launch {
            tilt.animateTo(26f, tween(420, easing = EaseOut))
            tilt.animateTo(0f, tween(620, easing = EaseIn))
        }
        // 눈이 갈리는 간격을 **점점 벌린다** — 회전이 느려지는 걸 눈이 따라간다
        scope.launch {
            var wait = 50L
            var spent = 0L
            while (spent < 1050) {
                delay(wait)
                spent += wait
                face = Random.nextInt(1, 7)
                wait = (wait * 1.2f).toLong()
            }
            face = pips
            // 착지 뒤 한 박자 두고 숫자를 띄운다 — 같이 나오면 굴러 멈춘 게 안 보인다
            delay(180)
            stage = DiceStage.Result(pips)
        }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(
            title = "주사위 굴리기",
            onBack = onClose,
            backIcon = R.drawable.ic_header_close,
            backDescription = "닫기",
        )

        Text(
            "하루 한 번",
            style = MyFisTheme.type.label,
            color = MyFisColor.TextSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth().padding(top = MyFisSpacing.lg),
        )

        Column(
            Modifier.weight(1f).fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Box(Modifier.size(width = 200.dp, height = 230.dp), Alignment.BottomCenter) {
                // 그림자가 높이를 알려 준다 — 뜨면 작아지고 옅어진다
                Canvas(Modifier.fillMaxSize()) {
                    val w = (96f - 36f * lift.value).dp.toPx()
                    val h = (18f - 7f * lift.value).dp.toPx()
                    drawOval(
                        color = Color.Black.copy(alpha = 0.5f - 0.34f * lift.value),
                        topLeft = Offset((size.width - w) / 2f, size.height - h),
                        size = Size(w, h),
                    )
                }

                DieFace(
                    face = face,
                    modifier = Modifier
                        .size(116.dp)
                        .offset(y = (-18).dp - (132.dp * lift.value))
                        .graphicsLayer {
                            rotationZ = spin.value
                            rotationX = tilt.value
                            rotationY = tilt.value * 0.45f
                            cameraDistance = 14f * density
                            val s = 1f + 0.10f * lift.value
                            scaleX = s
                            scaleY = s
                        },
                )
            }

            Box(Modifier.padding(top = MyFisSpacing.xxxl), contentAlignment = Alignment.Center) {
                val result = stage as? DiceStage.Result
                if (result == null) {
                    Text(
                        "나온 눈 하나당 $POINTS_PER_PIP P",
                        style = MyFisTheme.type.bodySm,
                        color = MyFisColor.TextTertiary,
                    )
                } else {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            "${result.pips}${particle(result.pips)} 나왔어요",
                            style = MyFisTheme.type.titleSm,
                            color = MyFisColor.TextPrimary,
                        )
                        Text(
                            "+${result.pips * POINTS_PER_PIP} P",
                            style = MyFisTheme.type.metricMd,
                            color = MyFisColor.Accent,
                            modifier = Modifier.padding(top = MyFisSpacing.xs),
                        )
                    }
                }
            }
        }

        MyFisPrimaryButton(
            text = when (val st = stage) {
                DiceStage.Idle -> "굴리기"
                DiceStage.Rolling -> "구르는 중"
                is DiceStage.Result -> "+${st.pips * POINTS_PER_PIP} P 받기"
            },
            enabled = stage != DiceStage.Rolling,
            onClick = { if (stage is DiceStage.Result) onClose() else if (stage == DiceStage.Idle) roll() },
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.xxxl),
        )
    }
}

/** 주사위 한 면. 눈은 **3×3 격자**의 정해진 자리에 찍는다 — 진짜 주사위와 같은 배치라야 읽힌다. */
@Composable
private fun DieFace(face: Int, modifier: Modifier = Modifier) {
    Canvas(modifier) {
        val side = minOf(size.width, size.height)
        val pip = side * 0.17f
        val inset = side * 0.20f
        val step = (side - inset * 2f - pip) / 2f

        drawRoundRect(
            color = MyFisColor.CategoryOrange,
            size = Size(side, side),
            cornerRadius = CornerRadius(side * 0.22f),
        )
        PIP_LAYOUT.getValue(face).forEach { (col, row) ->
            drawCircle(
                color = MyFisColor.OnAccent,
                radius = pip / 2f,
                center = Offset(inset + step * col + pip / 2f, inset + step * row + pip / 2f),
            )
        }
    }
}

/** 각 눈이 차지하는 격자 자리 (열, 행) */
private val PIP_LAYOUT: Map<Int, List<Pair<Int, Int>>> = mapOf(
    1 to listOf(1 to 1),
    2 to listOf(0 to 0, 2 to 2),
    3 to listOf(0 to 0, 1 to 1, 2 to 2),
    4 to listOf(0 to 0, 2 to 0, 0 to 2, 2 to 2),
    5 to listOf(0 to 0, 2 to 0, 1 to 1, 0 to 2, 2 to 2),
    6 to listOf(0 to 0, 0 to 1, 0 to 2, 2 to 0, 2 to 1, 2 to 2),
)

/** 숫자를 한자음으로 읽었을 때의 주격 조사 — 일**이**, 이**가**, 삼**이**, 사**가**, 오**가**, 육**이** */
private fun particle(pips: Int): String =
    mapOf(1 to "이", 2 to "가", 3 to "이", 4 to "가", 5 to "가", 6 to "이")[pips] ?: "이"

/** 눈 하나당 받는 P. `나온 눈만큼` 을 1~6 P 로 두면 출석(+50 P) 옆에서 너무 초라하다 */
private const val POINTS_PER_PIP = 10

sealed interface DiceStage {
    data object Idle : DiceStage
    data object Rolling : DiceStage
    data class Result(val pips: Int) : DiceStage
}
