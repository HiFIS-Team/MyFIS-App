package com.myfis.app.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.requiredSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisTheme
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.sin

/** 활동 랜딩의 **연출 상태** (DESIGN.md §6.25) */
enum class ActivityStage {
    /** 대기 — 그림이 은은하게 떠 있다 */
    IDLE,

    /** 재생 중 — 버튼은 눌리지 않는다 */
    PLAYING,

    /** 끝났다 — 받은 P 가 남는다 */
    RESULT,
}

/**
 * 연출은 **진행값 하나(0→1)** 로 굴린다.
 *
 * 단계마다 애니메이션을 따로 걸면 두 플랫폼이 미세하게 어긋나고, 중간에 끊어 되돌리기도 어렵다.
 * 진행값에서 자리·각도·투명도를 **계산해서** 그리면 iOS·Android 가 같은 장면을 그린다.
 */
object Stagecraft {
    /** `from`~`to` 구간을 0~1 로 자른다. 구간 밖은 0 또는 1 */
    fun slice(p: Float, from: Float, to: Float): Float =
        ((p - from) / (to - from)).coerceIn(0f, 1f)

    /** 시작과 끝이 부드러운 곡선 (구간 안에서만) */
    fun ease(t: Float): Float =
        if (t < 0.5f) 2 * t * t else 1 - (-2 * t + 2).toDouble().pow(2.0).toFloat() / 2
}

/** 뽑기 — **캡슐이 떨리다 갈라지고 P 가 튀어나온다** */
@Composable
fun LuckStage(color: Color, progress: Float, reward: String) {
    // 0.0 떨림 → 0.25 갈라짐 → 0.45 P 등장 → 0.75 반짝이
    val shake = Stagecraft.slice(progress, 0f, 0.25f)
    val split = Stagecraft.ease(Stagecraft.slice(progress, 0.25f, 0.55f))
    val reveal = Stagecraft.ease(Stagecraft.slice(progress, 0.45f, 0.75f))
    val settle = Stagecraft.slice(progress, 0.75f, 1f)

    // 갈라지기 전까지 부르르 — 곧 열린다는 예고다
    val wobble = if (shake >= 1f) 0f else sin(shake * Math.PI.toFloat() * 6) * 7f

    Box(contentAlignment = Alignment.Center) {
        Half(color, top = true, rotation = wobble - 24f * split, dy = -86f * split, alpha = 1f - 0.45f * split)
        Half(color.copy(alpha = 0.72f), top = false, rotation = wobble + 24f * split, dy = 86f * split, alpha = 1f - 0.45f * split)

        // 반짝이는 **갈라진 뒤에** 퍼진다. 같이 터지면 뭐가 나온 건지 안 보인다
        repeat(8) { i ->
            val angle = i / 8f * 2 * Math.PI.toFloat()
            Box(
                Modifier
                    .offset(x = (cos(angle) * 96f * settle).dp, y = (sin(angle) * 96f * settle).dp)
                    .size(8.dp)
                    .alpha(reveal * (1f - settle))
                    .background(color, MyFisRadius.full),
            )
        }

        RewardText(reward, color, reveal, settle)
    }
}

/**
 * 캡슐 반쪽. 위는 밝고 아래는 어둡다.
 *
 * **`Canvas` 로 반원을 직접 그린다.** 원을 네모로 잘라 보려다 두 번 실패했다 —
 * 부모 크기에 눌려 알약이 되거나(`size`), 잘리지 않고 통째로 남는다 (확인함).
 */
@Composable
private fun Half(color: Color, top: Boolean, rotation: Float, dy: Float, alpha: Float) {
    // 대기 글리프(148 안의 원 ≈ 지름 100)와 크기를 맞춰야 재생 순간 안 튄다
    Canvas(
        Modifier
            .size(100.dp)
            .graphicsLayer {
                rotationZ = rotation
                translationY = dy * density
                this.alpha = alpha
            },
    ) {
        drawArc(
            brush = Brush.verticalGradient(listOf(color, color.copy(alpha = 0.62f))),
            // 0° 가 3시, 시계 방향이다 — 위 반쪽은 180°에서 반 바퀴
            startAngle = if (top) 180f else 0f,
            sweepAngle = 180f,
            useCenter = true,
        )
    }
}

/** 사다리 — **점이 길을 타고 내려가고, 당첨 칸 종이가 뜯긴다** */
@Composable
fun LadderStage(color: Color, progress: Float, reward: String) {
    val walk = Stagecraft.slice(progress, 0.1f, 0.68f)
    val tear = Stagecraft.ease(Stagecraft.slice(progress, 0.68f, 0.84f))
    val reveal = Stagecraft.ease(Stagecraft.slice(progress, 0.78f, 1f))

    val dot = ladderDot(walk)

    Box(contentAlignment = Alignment.Center) {
        // 결과가 나오면 사다리는 **물러난다**. 안 그러면 숫자가 기둥에 걸쳐 안 읽힌다
        Box(Modifier.alpha(1f - 0.72f * reveal), contentAlignment = Alignment.Center) {
            Ladder(color)

            // 걸어 내려가는 점 — **흰 점**이다. 같은 색이면 기둥에 묻혀 안 보인다 (확인함)
            Box(
                Modifier
                    .offset(x = dot.x.dp, y = dot.y.dp)
                    .size(14.dp)
                    .alpha(if (walk > 0f) 1f else 0f)
                    .background(MyFisColor.TextPrimary, MyFisRadius.full),
            )

            // 당첨 칸 — 도착하면 **뜯겨 떨어진다**
            Box(
                Modifier
                    .offset(
                        x = (-LADDER_GAP / 2).dp,
                        y = (LADDER_HEIGHT / 2 + 26 + 52 * tear).dp,
                    )
                    .graphicsLayer {
                        rotationZ = 30f * tear
                        transformOrigin = TransformOrigin(0f, 0f)
                        alpha = 1f - tear
                    }
                    .size(width = (LADDER_GAP + 10).dp, height = 24.dp)
                    .background(color.copy(alpha = 0.9f), MyFisRadius.md),
                contentAlignment = Alignment.Center,
            ) {
                Box(
                    Modifier
                        .size(width = 26.dp, height = 4.dp)
                        .background(MyFisColor.BgBase.copy(alpha = 0.35f), MyFisRadius.full),
                )
            }
        }

        RewardText(reward, color, reveal, 0f)
    }
}

/**
 * 왼쪽 기둥에서 출발해 가로대를 만날 때마다 건너간다.
 * **오른쪽으로 두 번 건너가는 길**을 고정으로 쓴다 — 결과는 어차피 서버가 정한다
 */
private fun ladderDot(walk: Float): Offset {
    val left = -LADDER_GAP / 2
    val right = LADDER_GAP / 2
    val top = -LADDER_HEIGHT / 2
    val mid1 = -LADDER_HEIGHT / 6
    val mid2 = LADDER_HEIGHT / 6
    val bottom = LADDER_HEIGHT / 2
    val legs = listOf(
        Offset(left, top) to Offset(left, mid1),
        Offset(left, mid1) to Offset(right, mid1),
        Offset(right, mid1) to Offset(right, mid2),
        Offset(right, mid2) to Offset(left, mid2),
        Offset(left, mid2) to Offset(left, bottom),
    )
    val step = walk * legs.size
    val index = step.toInt().coerceAtMost(legs.size - 1)
    val t = step - index
    val (from, to) = legs[index]
    return Offset(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t)
}

/** 기둥 둘 + 가로대 셋. 굵기도 아이콘에서 가져왔다 (24 기준 2.6 → 148 기준 16) */
@Composable
private fun Ladder(color: Color) {
    Box(contentAlignment = Alignment.Center) {
        listOf(-1f, 1f).forEach { side ->
            Box(
                Modifier
                    .offset(x = (LADDER_GAP / 2 * side).dp)
                    .size(width = 15.dp, height = LADDER_HEIGHT.dp)
                    .background(color.copy(alpha = 0.9f), MyFisRadius.full),
            )
        }
        listOf(-1f, 0f, 1f).forEach { row ->
            Box(
                Modifier
                    .offset(y = (LADDER_HEIGHT / 6 * row * 2).dp)
                    .size(width = LADDER_GAP.dp, height = 13.dp)
                    .background(color.copy(alpha = 0.6f), MyFisRadius.full),
            )
        }
    }
}

/** 연출 끝에 나오는 값. **커졌다 제자리로** — 그냥 떠오르면 받은 느낌이 안 난다 */
@Composable
private fun RewardText(text: String, color: Color, reveal: Float, settle: Float) {
    Text(
        text,
        style = MyFisTheme.type.metricLg.copy(fontFeatureSettings = "tnum"),
        color = color,
        modifier = Modifier.graphicsLayer {
            val s = 0.4f + 0.78f * reveal - 0.16f * settle
            scaleX = s
            scaleY = s
            alpha = reveal
        },
    )
}

// 대기 글리프(사다리 아이콘)와 같은 크기여야 재생 순간 안 튄다
private const val LADDER_GAP = 54f
private const val LADDER_HEIGHT = 106f
