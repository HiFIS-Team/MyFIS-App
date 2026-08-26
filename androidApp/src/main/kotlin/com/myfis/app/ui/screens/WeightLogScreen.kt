package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.snapping.rememberSnapFlingBehavior
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import kotlin.math.abs
import kotlin.math.roundToInt
import kotlinx.coroutines.flow.drop

/**
 * SPEC.md P-08 체중 기록 (DESIGN.md §6.24).
 *
 * **체중계 표시부를 조절하는 화면이다.** 숫자 키패드를 띄우지 않는다 —
 * 오늘 몸무게는 어제 값에서 조금 움직이는 값이라, 처음부터 치는 것보다 **밀어서 맞추는 게 빠르다.**
 *
 * 숫자는 가운데 고정이고 **밑의 눈금자가 움직인다** (체중계 창을 돌리는 느낌).
 */
@Composable
fun WeightLogScreen(
    onBack: () -> Unit,
    // TODO(서버): 기록을 올린다. `User.weightKg` 도 이 값으로 갱신된다 (SPEC P-08)
    onSave: (Double) -> Unit = {},
) {
    // 눈금 하나 = 0.1kg. 정수(727)로 다뤄야 0.1 을 더할 때 오차가 안 쌓인다
    val state = rememberLazyListState(
        initialFirstVisibleItemIndex = weightLastTick - weightTickRange.first,
    )
    val spacingPx = with(LocalDensity.current) { weightTickSpacing.toPx() }
    val tick by remember(spacingPx) {
        derivedStateOf {
            val offset = (state.firstVisibleItemScrollOffset / spacingPx).roundToInt()
            weightTickRange.first + state.firstVisibleItemIndex + offset
        }
    }
    val value = tick / 10.0
    val diff = value - weightLastKg

    // 0.1 이 넘어갈 때마다 손끝에 걸리는 느낌을 준다 (§6.7)
    val haptics = LocalHapticFeedback.current
    LaunchedEffect(state) {
        snapshotFlow { tick }
            .drop(1) // 들어오자마자 울리면 안 된다
            .collect { haptics.performHapticFeedback(HapticFeedbackType.SegmentTick) }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(title = "체중 기록", onBack = onBack)

        Spacer(Modifier.weight(1f))

        // 체중계 창 — 숫자가 주인공이라 metric.xl. 자릿수가 바뀌어도 안 흔들리게 tnum
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.Center,
            verticalAlignment = Alignment.Bottom,
        ) {
            Text(
                "%.1f".format(value),
                style = MyFisTheme.type.metricXl.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
            )
            Text(
                "kg",
                style = MyFisTheme.type.titleMd,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(start = MyFisSpacing.sm, bottom = 10.dp),
            )
        }

        // **증감에 좋고 나쁨 색을 붙이지 않는다** (SPEC P-08) — 체중이 느는 게 목표인 사람도 있다
        Text(
            weightDiffLabel(diff),
            style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.sm),
        )

        WeightRuler(state, Modifier.padding(top = MyFisSpacing.xxxl))

        Spacer(Modifier.weight(1f))

        // TODO: 하루 1회만 적립된다 (여러 번 기록은 가능) — 서버가 판정한다
        MyFisPrimaryButton(
            text = "기록하고 +20 P 받기",
            onClick = {
                onSave(value)
                onBack()
            },
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.xxxl),
        )
    }
}

/**
 * 가로 눈금자 — **숫자는 가만히 있고 눈금이 흐른다.**
 *
 * 눈금 한 칸이 `0.1kg`, 1kg 마다 긴 눈금과 숫자를 둔다.
 * 가운데 표시선에 걸린 눈금이 곧 값이다.
 */
@Composable
private fun WeightRuler(state: LazyListState, modifier: Modifier = Modifier) {
    // 표시선은 **눈금 줄에만** 걸친다. 숫자 줄까지 내려오면 눈금이 아니라 화면을 가르는 선이 된다
    BoxWithConstraints(modifier.fillMaxWidth(), contentAlignment = Alignment.TopCenter) {
        val sideMargin = (maxWidth - weightTickSpacing) / 2

        LazyRow(
            state = state,
            flingBehavior = rememberSnapFlingBehavior(state),
            contentPadding = PaddingValues(horizontal = sideMargin),
            verticalAlignment = Alignment.Top,
        ) {
            items(weightTickRange.count()) { index ->
                Tick(weightTickRange.first + index)
            }
        }

        // 가운데 표시선 — **이 화면의 라임 한 곳** (§3.2)
        Box(
            Modifier
                .width(3.dp)
                .height(32.dp)
                .background(MyFisColor.Accent, MyFisRadius.full),
        )
    }
}

/** 눈금 하나. 1kg 는 길고 숫자까지, 0.5kg 는 중간, 나머지는 짧게 */
@Composable
private fun Tick(value: Int) {
    val isWhole = value % 10 == 0
    val isHalf = value % 5 == 0

    Column(
        modifier = Modifier.width(weightTickSpacing),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier
                .width(if (isWhole) 2.dp else 1.dp)
                .height(if (isWhole) 28.dp else if (isHalf) 20.dp else 14.dp)
                .background(
                    if (isWhole) MyFisColor.TextSecondary else MyFisColor.BorderSubtle,
                    MyFisRadius.full,
                ),
        )
        if (isWhole) {
            Text(
                "${value / 10}",
                style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextTertiary,
                maxLines = 1,
                // 눈금 칸(10dp)보다 숫자가 넓다. 칸 밖으로 넘치게 두지 않으면 두 줄로 접힌다
                modifier = Modifier
                    .padding(top = MyFisSpacing.sm)
                    .wrapContentWidth(unbounded = true),
            )
        } else {
            Spacer(Modifier.size(0.dp))
        }
    }
}

private fun weightDiffLabel(diff: Double): String {
    val last = "%.1f".format(weightLastKg)
    if (abs(diff) < 0.05) return "지난 기록 $last kg 과 같아요"
    val sign = if (diff > 0) "+" else "−"
    return "지난 기록 $last kg 보다 $sign${"%.1f".format(abs(diff))} kg"
}

/** 30.0 ~ 150.0 kg. 이 밖은 입력할 일이 없다 */
private val weightTickRange = 300..1500

/** 눈금 사이 간격. 좁으면 0.1 을 집기 어렵고 넓으면 10kg 옮기는 데 몇 번을 쓸어야 한다 */
private val weightTickSpacing = 10.dp

// TODO(서버): 마지막 기록은 서버가 준다. 처음이면 가입(A-06)에서 받은 값을 쓴다
const val weightLastKg = 72.7
val weightLastTick = (weightLastKg * 10).roundToInt()
