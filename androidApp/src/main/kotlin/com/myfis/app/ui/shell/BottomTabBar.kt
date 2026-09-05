package com.myfis.app.ui.shell

import androidx.compose.animation.ExperimentalSharedTransitionApi
import androidx.compose.animation.animateBounds
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.key
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.LookaheadScope
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics
import kotlinx.coroutines.delay

/**
 * DESIGN.md §6.7 하단 탭 (Android). 레퍼런스: 토스.
 *
 * 세트에 따라 모양이 다르다.
 * - **기본 세트**: 화면 아래에 **붙는다.** 폭을 꽉 채우고 **위쪽 모서리만** 둥글다
 * - **웨이트 세트**: **떠 있다.** 좌우 여백을 두고 네 모서리가 다 둥글다
 *
 * 붙어 있으면 원래 자리, 떠 있으면 잠깐 들어와 있는 곳이라는 신호다.
 *
 * **전환 애니메이션** — 바를 새로 그리지 않는다.
 * 1. 바가 아래에서 **떠오르며** 모서리가 둥글어진다
 * 2. `웨이트` 는 사라졌다 나타나지 않고 **4번째 자리에서 2번째 자리로 이동**한다 (`animateBounds`)
 * 3. `유산소`·`랭킹`·`모임` 이 **차례로** 나타난다
 * 4. `이전` 원형 버튼이 커지며 등장한다
 *
 * 나가기는 그대로 역방향이다.
 */
@OptIn(ExperimentalSharedTransitionApi::class)
@Composable
fun MyFisTabBar(
    tabSet: TabSet,
    baseTab: BaseTab,
    weightTab: WeightTab,
    onBaseSelect: (BaseTab) -> Unit,
    onWeightSelect: (WeightTab) -> Unit,
    modifier: Modifier = Modifier,
) {
    val floating = tabSet == TabSet.WEIGHT
    val navInset = WindowInsets.navigationBars.asPaddingValues().calculateBottomPadding()

    // ⚠️ 스프링은 목표값 아래로 **오버슈트**한다. 0 으로 수렴하는 값이 음수가 되는 순간
    // padding / corner radius 가 터진다 ("Padding must be non-negative" 로 앱이 죽었다).
    // 애니메이션 결과는 반드시 0 이상으로 막는다.
    val geometry = spring<Dp>(dampingRatio = 0.85f, stiffness = 380f)
    val sidePadRaw by animateDpAsState(if (floating) MyFisSpacing.md else 0.dp, geometry, label = "sidePad")
    val liftPadRaw by animateDpAsState(if (floating) navInset + MyFisSpacing.sm else 0.dp, geometry, label = "liftPad")
    val innerBottomRaw by animateDpAsState(if (floating) 0.dp else navInset, geometry, label = "innerBottom")
    val bottomRadiusRaw by animateDpAsState(if (floating) 28.dp else 0.dp, geometry, label = "bottomRadius")

    val sidePad = sidePadRaw.coerceAtLeast(0.dp)
    val liftPad = liftPadRaw.coerceAtLeast(0.dp)
    val innerBottom = innerBottomRaw.coerceAtLeast(0.dp)
    val bottomRadius = bottomRadiusRaw.coerceAtLeast(0.dp)

    // 두 세트가 **같은 key** 를 써야 `웨이트` 가 사라졌다 나타나지 않고 자리만 옮긴다.
    // if/else 로 갈라 그리면 key 가 달라져 remove+add 가 되고, 이동 애니메이션이 안 나온다.
    val slots: List<BarSlot> = if (floating) {
        listOf(
            BarSlot("back", WeightTab.BACK, isExit = true) { onWeightSelect(WeightTab.BACK) },
        ) + WeightTab.entries.filter { it != WeightTab.BACK }.map { tab ->
            BarSlot(tab.slotKey, tab, selected = tab == weightTab) { onWeightSelect(tab) }
        }
    } else {
        BaseTab.entries.map { tab ->
            BarSlot(tab.slotKey, tab, selected = tab == baseTab) { onBaseSelect(tab) }
        }
    }

    LookaheadScope {
        Row(
            modifier = modifier
                .fillMaxWidth()
                .padding(start = sidePad, end = sidePad, bottom = liftPad)
                // 떠 있을 때는 **살짝 비친다** (§6.7) — 바 아래가 칼로 자른 듯 끊기지 않게.
                // 붙어 있을 때는 화면 끝이라 비칠 것이 없으므로 그대로 둔다
                .background(
                    // ⚠️ 떠 있을 때 **살짝 비치게** 뒀다가 되돌렸다 🟢 (2026-09-06, 사용자 지정) —
                    // 바 안에서 뒤 글자가 비쳐 **바가 더러워 보였다.** 바는 불투명하다.
                    // 콘텐츠가 바 **밑으로 흐르는 것**(§6.7)은 그대로다 — 그게 "떠 있음"을 낸다
                    MyFisColor.Surface2,
                    RoundedCornerShape(
                        topStart = 28.dp,
                        topEnd = 28.dp,
                        bottomStart = bottomRadius,
                        bottomEnd = bottomRadius,
                    ),
                )
                .padding(bottom = innerBottom)
                .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.sm),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            var appearIndex = 0
            slots.forEach { slot ->
                key(slot.key) {
                    val bounds = Modifier.animateBounds(this@LookaheadScope)
                    when {
                        slot.isExit -> ExitButton(
                            tab = slot.tab,
                            onClick = slot.onClick,
                            modifier = bounds,
                        )
                        // '웨이트' 는 양쪽 세트에 다 있으므로 등장 애니메이션을 주지 않는다.
                        // 자리 이동만 한다.
                        slot.key == WEIGHT_KEY -> TabItem(
                            slot = slot,
                            modifier = Modifier.weight(1f).then(bounds),
                        )
                        else -> {
                            // 첫 등장을 조금 늦춘다. '웨이트' 가 자리를 옮기는 동안
                            // 옆자리에 바로 나타나면 라벨이 겹쳐 보인다.
                            val delay = 60L + appearIndex++ * 70L
                            TabItem(
                                slot = slot,
                                modifier = Modifier
                                    .weight(1f)
                                    .then(bounds)
                                    .appearAfter(delay, tabSet),
                            )
                        }
                    }
                }
            }
        }
    }
}

private const val WEIGHT_KEY = "weight"

private val BaseTab.slotKey: String
    get() = if (this == BaseTab.WEIGHT) WEIGHT_KEY else "base_${'$'}name"

private val WeightTab.slotKey: String
    get() = if (this == WeightTab.WEIGHT) WEIGHT_KEY else "weight_${'$'}name"

private class BarSlot(
    val key: String,
    val tab: Tab,
    val selected: Boolean = false,
    val isExit: Boolean = false,
    val onClick: () -> Unit,
)

/**
 * 세트가 바뀔 때 [delayMillis] 만큼 늦게 나타난다.
 *
 * 초기값은 반드시 0 이어야 한다. 1 로 두면 첫 프레임에 다 보였다가
 * LaunchedEffect 가 0 으로 되돌리면서 **깜빡인다** (실제로 겪음).
 */
@Composable
private fun Modifier.appearAfter(delayMillis: Long, key: Any): Modifier {
    val progress = remember { Animatable(0f) }
    LaunchedEffect(key) {
        progress.snapTo(0f)
        delay(delayMillis)
        progress.animateTo(1f, tween(durationMillis = 200))
    }
    return this.graphicsLayer {
        alpha = progress.value
        translationY = (1f - progress.value) * 14.dp.toPx()
    }
}

/** 나가는 길. 다른 탭과 성격이 다르므로 원형 버튼으로 분리한다. */
@Composable
private fun ExitButton(tab: Tab, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val enter = remember { Animatable(0.5f) }
    LaunchedEffect(Unit) {
        enter.animateTo(1f, spring(dampingRatio = 0.6f, stiffness = 500f))
    }
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Box(
        modifier = modifier
            .padding(end = MyFisSpacing.sm)
            .size(48.dp)
            .graphicsLayer {
                scaleX = enter.value * press
                scaleY = enter.value * press
                alpha = enter.value.coerceIn(0f, 1f)
            }
            .background(MyFisColor.Surface3, CircleShape)
            .tapWithHaptics(interaction, onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(tab.icon),
            contentDescription = tab.label,
            tint = MyFisColor.TextSecondary,
            modifier = Modifier.size(24.dp),
        )
    }
}

@Composable
private fun TabItem(slot: BarSlot, modifier: Modifier = Modifier) {
    val label = slot.tab.label
    // 선택은 **색이 아니라 채움**으로 알린다 (DESIGN.md §6.7).
    // 실루엣은 그대로 두고 안쪽만 차므로 눌렀을 때 아이콘이 튀지 않는다.
    val icon = if (slot.selected) slot.tab.iconFill else slot.tab.icon
    val onClick = slot.onClick
    val tint: Color = if (slot.selected) MyFisColor.TextPrimary else MyFisColor.TextTertiary
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Column(
        modifier = modifier
            .tapWithHaptics(interaction, onClick)
            // 터치 타겟 48dp 확보 (DESIGN.md §5.3). 이 아래로 줄이지 않는다 —
            // 바 높이를 더 낮추려면 Row 의 vertical padding 을 줄인다
            .height(48.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = null, // 라벨이 바로 아래 있으므로 중복 읽지 않는다
            tint = tint,
            modifier = Modifier
                .size(26.dp)
                .graphicsLayer {
                    scaleX = press
                    scaleY = press
                },
        )
        Text(
            text = label,
            style = MyFisTheme.type.caption,
            color = tint,
            modifier = Modifier.padding(top = 4.dp),
        )
    }
}
