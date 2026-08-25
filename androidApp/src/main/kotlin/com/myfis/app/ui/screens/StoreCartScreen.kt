package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-06 장바구니 (DESIGN.md §6.22).
 *
 * 여러 상품을 **한 번에 교환**한다. 이 화면이 답해야 하는 건 상세와 같다 —
 * "지금 바꿀 수 있나". 다만 여기선 **고른 것들의 합계**가 그 답이다.
 */
@Composable
fun StoreCartScreen(
    onBack: () -> Unit,
    balance: Int = mileageBalancePlaceholder,
    onStore: () -> Unit = {},
    onExchange: () -> Unit = {},
) {
    var lines by remember { mutableStateOf(cartPlaceholder) }

    val picked = lines.filter { it.checked }
    val total = picked.sumOf { it.item.price * it.count }
    val short = (total - balance).coerceAtLeast(0)

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader("장바구니", onBack)

        if (lines.isEmpty()) {
            CartEmpty(onStore)
            return@Column
        }

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState()),
        ) {
            SelectAllRow(
                total = lines.size,
                allChecked = lines.all { it.checked },
                onToggleAll = { on -> lines = lines.map { it.copy(checked = on) } },
                onDeletePicked = { lines = lines.filterNot { it.checked } },
                anyChecked = picked.isNotEmpty(),
            )

            // 줄마다 카드를 떼지 않고 **한 장 안에서 구분선**으로 가른다 (§6.21 리뷰와 같은 판단)
            Column(
                Modifier
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    .clip(MyFisRadius.md)
                    .background(MyFisColor.Surface1),
            ) {
                lines.forEachIndexed { index, line ->
                    if (index > 0) CartDivider()
                    CartRow(
                        line = line,
                        onToggle = {
                            lines = lines.mapIndexed { i, l ->
                                if (i == index) l.copy(checked = !l.checked) else l
                            }
                        },
                        onCount = { next ->
                            lines = lines.mapIndexed { i, l ->
                                if (i == index) l.copy(count = next) else l
                            }
                        },
                        onDelete = { lines = lines.filterIndexed { i, _ -> i != index } },
                    )
                }
            }

            CartNotice()

            CartSuggestions(items = cartSuggestions(lines))
        }

        CartBar(
            count = picked.sumOf { it.count },
            total = total,
            short = short,
            onExchange = onExchange,
        )
    }
}

/** 전체 선택 ↔ 선택 삭제. 목록 위에 둔다 — 고르고 나서 지우는 순서라서다 */
@Composable
private fun SelectAllRow(
    total: Int,
    allChecked: Boolean,
    anyChecked: Boolean,
    onToggleAll: (Boolean) -> Unit,
    onDeletePicked: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.md,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            modifier = Modifier
                .clip(MyFisRadius.sm)
                .tapWithHaptics(interaction) { onToggleAll(!allChecked) }
                .padding(vertical = MyFisSpacing.xs, horizontal = MyFisSpacing.xs),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            CheckBox(checked = allChecked)
            Text(
                "전체 선택 (%,d건)".format(total),
                style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(start = MyFisSpacing.sm),
            )
        }
        Spacer(Modifier.weight(1f))
        if (anyChecked) {
            MyFisSmallButton("선택 삭제", onDeletePicked)
        }
    }
}

/**
 * 선택 표시.
 *
 * **색이 아니라 채움으로 알린다** (§6.7 하단 탭과 같은 판단) — 액센트는 하단 [교환하기] 몫이다.
 * 체크가 라임이면 화면에서 가장 중요한 게 뭔지 흐려진다.
 */
@Composable
private fun CheckBox(checked: Boolean) {
    Box(
        modifier = Modifier
            .size(CheckSize)
            .clip(MyFisRadius.sm)
            .then(
                if (checked) {
                    Modifier.background(MyFisColor.TextPrimary)
                } else {
                    Modifier.border(1.5.dp, MyFisColor.BorderStrong, MyFisRadius.sm)
                },
            ),
        contentAlignment = Alignment.Center,
    ) {
        if (checked) {
            Icon(
                painter = painterResource(R.drawable.ic_check),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                tint = MyFisColor.BgBase,
                modifier = Modifier.size(16.dp),
            )
        }
    }
}

private val CheckSize = 22.dp

/** 담긴 상품 한 줄 */
@Composable
private fun CartRow(
    line: CartLine,
    onToggle: () -> Unit,
    onCount: (Int) -> Unit,
    onDelete: () -> Unit,
) {
    val checkInteraction = remember { MutableInteractionSource() }
    val deleteInteraction = remember { MutableInteractionSource() }
    val deletePress by deleteInteraction.pressScale()

    Row(
        Modifier
            .fillMaxWidth()
            .padding(MyFisSpacing.cardPadding),
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .tapWithHaptics(checkInteraction, onToggle),
            contentAlignment = Alignment.Center,
        ) {
            CheckBox(checked = line.checked)
        }

        // TODO(서버): 상품 이미지가 오면 교체한다
        Box(
            Modifier
                .width(SuggestionThumb)
                .aspectRatio(1f)
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier.size(28.dp),
            )
        }

        Column(
            Modifier
                .weight(1f)
                .padding(start = MyFisSpacing.md),
        ) {
            Text(
                line.item.name,
                style = MyFisTheme.type.body,
                color = MyFisColor.TextPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Row(
                modifier = Modifier.padding(top = 2.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_mileage_fill),
                    contentDescription = null,
                    tint = MyFisColor.Accent,
                    modifier = Modifier.size(18.dp),
                )
                Text(
                    (line.item.price * line.count).toMileage(),
                    style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                    color = MyFisColor.TextPrimary,
                )
            }
            // 배송이 아니라 **지점 수령**이다 (SPEC S-01) — 도착 예정일 자리에 수령 방법을 적는다
            Text(
                "강남점 데스크 · 발급 후 7일 안에 수령",
                style = MyFisTheme.type.caption,
                color = MyFisColor.TextTertiary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.padding(top = MyFisSpacing.xs),
            )

            Row(
                modifier = Modifier.padding(top = MyFisSpacing.sm),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                Box(
                    modifier = Modifier
                        .size(StepperHeight)
                        .clip(MyFisRadius.sm)
                        .background(MyFisColor.Surface2)
                        .tapWithHaptics(deleteInteraction, onDelete),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        painter = painterResource(R.drawable.ic_cart_delete),
                        contentDescription = "삭제",
                        tint = MyFisColor.TextSecondary,
                        modifier = Modifier
                            .size(18.dp)
                            .graphicsLayer {
                                scaleX = deletePress
                                scaleY = deletePress
                            },
                    )
                }
                Stepper(count = line.count, onCount = onCount)
            }
        }
    }
}

/** 수량. 1 밑으로는 안 내려간다 — 0개는 삭제가 할 일이다 */
@Composable
private fun Stepper(count: Int, onCount: (Int) -> Unit) {
    Row(
        modifier = Modifier
            .height(StepperHeight)
            .clip(MyFisRadius.sm)
            .background(MyFisColor.Surface2),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        StepperButton("−", enabled = count > 1) { onCount(count - 1) }
        Text(
            "$count",
            style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
            modifier = Modifier.width(24.dp),
            maxLines = 1,
        )
        StepperButton("+", enabled = count < CartMax) { onCount(count + 1) }
    }
}

@Composable
private fun StepperButton(label: String, enabled: Boolean, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Box(
        modifier = Modifier
            .size(StepperHeight)
            .then(if (enabled) Modifier.tapWithHaptics(interaction, onClick) else Modifier),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = MyFisTheme.type.titleSm,
            color = if (enabled) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
        )
    }
}

private val StepperHeight = 34.dp
private val SuggestionThumb = 64.dp

@Composable
private fun CartDivider() {
    Box(
        Modifier
            .fillMaxWidth()
            .height(1.dp)
            .background(MyFisColor.BorderSubtle),
    )
}

/** 담아둔 것이 사라지는 조건을 **미리** 알린다. 사라진 뒤에 설명하면 늦다 */
@Composable
private fun CartNotice() {
    Column(
        Modifier.padding(
            horizontal = MyFisSpacing.screenHorizontal,
            vertical = MyFisSpacing.lg,
        ),
        verticalArrangement = Arrangement.spacedBy(2.dp),
    ) {
        // TODO(서버): 담기 한도·보관 기간은 정책이 정해지면 맞춘다
        Text(
            "* 한 번에 최대 ${CartMax}개까지 담을 수 있어요",
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
        )
        Text(
            "* 담은 지 30일이 지난 상품은 장바구니에서 사라져요",
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextTertiary,
        )
    }
}

/** 같이 담을 만한 것. 상세(§6.21)와 **같은 가로 줄**을 쓴다 */
@Composable
private fun CartSuggestions(items: List<StoreItem>) {
    if (items.isEmpty()) return

    Column(Modifier.padding(bottom = MyFisSpacing.xxxl)) {
        Text(
            "함께 담으면 좋아요",
            style = MyFisTheme.type.titleMd,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(horizontal = MyFisSpacing.screenHorizontal),
        )
        Row(
            Modifier
                .padding(top = MyFisSpacing.md)
                .padding(horizontal = MyFisSpacing.screenHorizontal),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
        ) {
            items.forEach { CartSuggestionCard(it, Modifier.weight(1f)) }
        }
    }
}

@Composable
private fun CartSuggestionCard(item: StoreItem, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    // TODO: 담기가 붙으면 연결한다
    Column(
        modifier
            .clip(MyFisRadius.md)
            .tapWithHaptics(interaction, {}),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier.size(40.dp),
            )
        }
        Text(
            item.name,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        Text(
            item.price.toMileage(),
            style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = 2.dp),
        )
    }
}

/**
 * 하단 고정 바.
 *
 * **합계를 버튼 바로 위에** 둔다 — 누르기 직전이 그 숫자를 볼 마지막 순간이다.
 * 못 바꾸는 이유는 상세(§6.21)와 같이 버튼 글자가 직접 말한다.
 */
@Composable
private fun CartBar(
    count: Int,
    total: Int,
    short: Int,
    onExchange: () -> Unit,
) {
    Column {
        CartDivider()
        Column(
            Modifier
                .fillMaxWidth()
                .background(MyFisColor.BgBase)
                .navigationBarsPadding()
                .padding(
                    horizontal = MyFisSpacing.screenHorizontal,
                    vertical = MyFisSpacing.md,
                ),
        ) {
            // 남는 잔액은 적지 않는다 — 못 바꿀 때의 이유는 **버튼 글자**가 말한다 (§6.21 과 같은 규칙)
            Text(
                "쓰는 마일리지",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
            )
            Row(
                modifier = Modifier.padding(top = 2.dp, bottom = MyFisSpacing.md),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_mileage_fill),
                    contentDescription = null,
                    tint = MyFisColor.Accent,
                    modifier = Modifier.size(22.dp),
                )
                Text(
                    total.toMileage(),
                    style = MyFisTheme.type.metricMd.copy(fontFeatureSettings = "tnum"),
                    color = MyFisColor.Accent,
                    modifier = Modifier.padding(start = MyFisSpacing.xs),
                )
            }
            MyFisPrimaryButton(
                text = when {
                    count == 0 -> "상품을 골라 주세요"
                    short > 0 -> "${short.toMileage()} 부족"
                    else -> "%,d개 교환하기".format(count)
                },
                onClick = onExchange,
                enabled = count > 0 && short == 0,
                modifier = Modifier.fillMaxWidth(),
            )
        }
    }
}

@Composable
private fun CartEmpty(onStore: () -> Unit) {
    Column(
        Modifier
            .fillMaxSize()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_header_cart),
            contentDescription = null,
            tint = MyFisColor.Surface3,
            modifier = Modifier.size(56.dp),
        )
        Text(
            "담은 상품이 없어요",
            style = MyFisTheme.type.titleSm,
            color = MyFisColor.TextSecondary,
            modifier = Modifier.padding(top = MyFisSpacing.md),
        )
        MyFisSecondaryButton(
            text = "상품 보러 가기",
            onClick = onStore,
            modifier = Modifier.padding(top = MyFisSpacing.lg),
        )
    }
}

/** 장바구니 한 줄. TODO(서버): 장바구니 API 가 붙으면 지운다 */
data class CartLine(
    val item: StoreItem,
    val count: Int = 1,
    val checked: Boolean = true,
)

/** 한 번에 담을 수 있는 개수. TODO(서버): 정책이 정해지면 맞춘다 */
const val CartMax = 10

/** TODO(서버): 장바구니 API 가 붙으면 지운다 */
val cartPlaceholder = listOf(
    CartLine(storeItemPlaceholder[0], count = 2),
    CartLine(storeItemPlaceholder[2]),
    CartLine(storeItemPlaceholder[6], checked = false),
)

/** 담은 것과 겹치지 않게 고른다. TODO(서버): 추천은 서버가 고른다 */
private fun cartSuggestions(lines: List<CartLine>): List<StoreItem> {
    val inCart = lines.map { it.item.id }.toSet()
    return storeItemPlaceholder
        .filter { it.id !in inCart && !it.soldOut }
        .sortedByDescending { it.views }
        .take(2)
}
