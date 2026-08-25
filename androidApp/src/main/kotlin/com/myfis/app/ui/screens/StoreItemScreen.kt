package com.myfis.app.ui.screens

import androidx.compose.foundation.background
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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-02 상품 상세 (DESIGN.md §6.21).
 *
 * 이 화면이 답해야 하는 건 하나다 — **"이거 지금 바꿀 수 있나?"**
 * 그래서 가격 밑에 곧바로 교환 후 잔액(또는 부족분)을 붙이고, 하단 버튼이 같은 말을 반복한다.
 */
@Composable
fun StoreItemScreen(
    item: StoreItem,
    balance: Int = mileageBalancePlaceholder,
    onBack: () -> Unit,
    onSearch: () -> Unit = {},
    onCart: () -> Unit = {},
    onExchange: () -> Unit = {},
) {
    val short = (item.price - balance).coerceAtLeast(0)
    var liked by rememberSaveable(item.id) { mutableStateOf(false) }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase),
    ) {
        Box(Modifier.weight(1f)) {
            Column(Modifier.verticalScroll(rememberScrollState())) {
                ItemImage()
                ItemHead(item = item, short = short, balance = balance)
                ItemFacts(item = item)
                ItemReviews(item = item, reviews = storeReviewPlaceholder)
            }

            // **버튼은 스크롤을 따라가지 않는다.** 내려 읽다가 뒤로가기가 사라지면 안 된다
            Row(
                modifier = Modifier
                    .statusBarsPadding()
                    .fillMaxWidth()
                    .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                FloatingIcon(R.drawable.ic_tab_back, "뒤로", onBack)
                Spacer(Modifier.weight(1f))
                // TODO: S-07 검색 · S-06 장바구니가 붙으면 연결한다
                FloatingIcon(R.drawable.ic_header_search, "검색", onSearch)
                FloatingIcon(R.drawable.ic_header_cart, "장바구니", onCart)
            }
        }

        BuyBar(
            item = item,
            short = short,
            liked = liked,
            onLike = { liked = !liked },
            onCart = onCart,
            onExchange = onExchange,
        )
    }
}

/** 상품 이미지. 위 버튼들은 이미지 **위에 떠 있다** — 이미지를 화면 끝까지 쓰기 위해서다 */
@Composable
private fun ItemImage() {
    Box(
        Modifier
            .fillMaxWidth()
            .aspectRatio(1f)
            .background(MyFisColor.Surface2),
        contentAlignment = Alignment.Center,
    ) {
        // TODO(서버): 상품 이미지가 오면 교체한다
        Icon(
            painter = painterResource(R.drawable.ic_tab_store),
            contentDescription = null,
            tint = MyFisColor.Surface3,
            modifier = Modifier.size(96.dp),
        )

    }
}

/**
 * 이미지 위에 뜨는 아이콘.
 *
 * **배경(원)을 깔지 않는다.** 아이콘만 얹어야 사진이 안 가린다 —
 * iOS 는 시스템 유리 버튼이 같은 자리를 맡는다 (플랫폼이 주는 것을 그대로 쓴다, §6.7 과 같은 판단).
 */
@Composable
private fun FloatingIcon(icon: Int, label: String, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Box(
        modifier = Modifier
            .size(44.dp)
            .clip(CircleShape)
            .tapWithHaptics(interaction, onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = label,
            tint = MyFisColor.TextPrimary,
            modifier = Modifier
                .size(24.dp)
                .graphicsLayer {
                    scaleX = press
                    scaleY = press
                },
        )
    }
}

/** 분류·이름·가격, 그리고 **바꿀 수 있는지** */
@Composable
private fun ItemHead(item: StoreItem, short: Int, balance: Int) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.lg,
            ),
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm)) {
            Chip(item.category.label)
            Chip("인기 ${popularityRank(item)}위")
        }

        Text(
            item.name,
            style = MyFisTheme.type.titleLg,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = MyFisSpacing.md),
        )

        Row(
            modifier = Modifier.padding(top = MyFisSpacing.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_mileage_fill),
                contentDescription = null, // 옆 숫자가 이름 역할을 한다
                tint = MyFisColor.Accent,
                modifier = Modifier.size(26.dp),
            )
            Text(
                item.price.toMileage(),
                style = MyFisTheme.type.metricLg.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
            )
        }

        // 가격 바로 밑에서 **바꿀 수 있는지**를 답한다. 하단 버튼까지 내려가서 알 일이 아니다
        Text(
            when {
                item.soldOut -> "지금은 품절이에요"
                short > 0 -> "${short.toMileage()} 더 모으면 교환할 수 있어요"
                else -> "교환하면 ${(balance - item.price).toMileage()} 남아요"
            },
            style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
            color = if (short > 0 || item.soldOut) MyFisColor.Warning else MyFisColor.TextSecondary,
            modifier = Modifier.padding(top = MyFisSpacing.xs),
        )
    }
}

@Composable
private fun Chip(label: String) {
    Text(
        label,
        style = MyFisTheme.type.label,
        color = MyFisColor.TextSecondary,
        modifier = Modifier
            .background(MyFisColor.Surface2, MyFisRadius.sm)
            .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.xs),
    )
}

/** 나머지 사실들. 한 줄에 하나씩, 라벨은 왼쪽으로 폭을 고정해 값이 세로로 정렬된다 */
@Composable
private fun ItemFacts(item: StoreItem) {
    Column(Modifier.fillMaxWidth()) {
        Divider()
        FactRow("평점 · 리뷰", "%.1f (%,d)".format(item.rating, item.reviewCount), chevron = true)
        FactRow("조회", item.views.toViewCount())
        FactRow("수령", "지점 데스크에서 받아요", chevron = true)
        FactRow("교환권", "발급 후 7일 안에 수령")
        Divider()
    }
}

@Composable
private fun FactRow(label: String, value: String, chevron: Boolean = false) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .then(if (chevron) Modifier.tapWithHaptics(interaction, {}) else Modifier)
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.md,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            label,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            modifier = Modifier.size(width = 88.dp, height = 20.dp),
        )
        Text(
            value,
            style = MyFisTheme.type.body.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )
        if (chevron) {
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier
                    .size(18.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

@Composable
private fun Divider() {
    Box(
        Modifier
            .fillMaxWidth()
            .height(1.dp)
            .background(MyFisColor.BorderSubtle),
    )
}

/**
 * 하단 고정 바 (§6.21).
 *
 * **엄지가 닿는 자리**라 이 화면의 유일한 Primary 를 여기 둔다 (§2 원칙 2·5).
 * 못 바꾸는 이유는 버튼 글자가 직접 말한다 — 비활성만 시키고 이유를 안 적으면 사용자가 막힌다.
 */
@Composable
private fun BuyBar(
    item: StoreItem,
    short: Int,
    liked: Boolean,
    onLike: () -> Unit,
    onCart: () -> Unit,
    onExchange: () -> Unit,
) {
    val cartInteraction = remember { MutableInteractionSource() }
    val cartPress by cartInteraction.pressScale()

    Column {
        Divider()
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(MyFisColor.BgBase)
                .navigationBarsPadding()
                .padding(
                    horizontal = MyFisSpacing.screenHorizontal,
                    vertical = MyFisSpacing.md,
                ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            // 스토어 그리드와 **같은 하트**를 쓴다 — 누를 때 반응(팝 + 고리)까지 같아야 한 앱으로 읽힌다
            LikeButton(liked = liked, onClick = onLike, box = BarIconBox, icon = BarIconSize)
            Box(
                modifier = Modifier
                    .size(BarIconBox)
                    .clip(CircleShape)
                    .tapWithHaptics(cartInteraction, onCart),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_header_cart),
                    contentDescription = "장바구니",
                    tint = MyFisColor.TextSecondary,
                    modifier = Modifier
                        .size(BarIconSize)
                        .graphicsLayer {
                            scaleX = cartPress
                            scaleY = cartPress
                        },
                )
            }
            MyFisPrimaryButton(
                text = when {
                    item.soldOut -> "품절"
                    short > 0 -> "${short.toMileage()} 부족"
                    else -> "교환하기"
                },
                onClick = onExchange,
                enabled = !item.soldOut && short == 0,
                modifier = Modifier.weight(1f),
            )
        }
    }
}

/**
 * 리뷰 (DESIGN.md §6.21).
 *
 * **상품 설명은 두지 않는다.** 파워에이드가 뭔지 설명할 이유가 없다 —
 * 사람들이 궁금한 건 "이거 받아보니 어땠나" 뿐이라 리뷰만 남긴다.
 */
@Composable
private fun ItemReviews(item: StoreItem, reviews: List<StoreReview>) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        Modifier
            .fillMaxWidth()
            .padding(top = MyFisSpacing.xl, bottom = MyFisSpacing.md),
    ) {
        Row(
            modifier = Modifier.padding(horizontal = MyFisSpacing.screenHorizontal),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Text("리뷰", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
            Text(
                "%,d개".format(item.reviewCount),
                style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(bottom = 2.dp),
            )
        }

        Row(
            modifier = Modifier.padding(
                start = MyFisSpacing.screenHorizontal,
                top = MyFisSpacing.md,
                bottom = MyFisSpacing.md,
            ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Stars(item.rating.toInt(), size = 18.dp)
            Text(
                "%.1f".format(item.rating),
                style = MyFisTheme.type.titleMd.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
            )
        }

        reviews.forEach { review ->
            Divider()
            ReviewRow(review)
        }
        Divider()

        // TODO: 전체 리뷰 목록(🔵)이 붙으면 연결한다
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .tapWithHaptics(interaction, {})
                .padding(
                    horizontal = MyFisSpacing.screenHorizontal,
                    vertical = MyFisSpacing.lg,
                ),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
        ) {
            Text(
                "리뷰 %,d개 모두 보기".format(item.reviewCount),
                style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextSecondary,
            )
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier
                    .size(18.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

@Composable
private fun ReviewRow(review: StoreReview) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        Modifier
            .fillMaxWidth()
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.lg,
            ),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Stars(review.rating, size = 14.dp)
            Text(review.author, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            Text(review.date, style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
        }

        Text(
            review.body,
            style = MyFisTheme.type.body,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )

        // TODO(서버): 도움 됐어요 집계가 붙으면 실제로 누르게 한다
        Text(
            "도움 됐어요 ${review.helpful}",
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextSecondary,
            modifier = Modifier
                .padding(top = MyFisSpacing.md)
                .clip(MyFisRadius.sm)
                .background(MyFisColor.Surface2)
                .tapWithHaptics(interaction, {})
                .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
        )
    }
}

/** 별 다섯 개. 채운 별은 `rating`, 나머지는 표면색으로 남긴다 */
@Composable
private fun Stars(filled: Int, size: androidx.compose.ui.unit.Dp) {
    Row(horizontalArrangement = Arrangement.spacedBy(1.dp)) {
        repeat(5) { index ->
            Icon(
                painter = painterResource(R.drawable.ic_store_rating),
                contentDescription = null, // 옆 숫자가 이름 역할을 한다
                tint = if (index < filled) MyFisColor.Rating else MyFisColor.Surface3,
                modifier = Modifier.size(size),
            )
        }
    }
}

/** 하단 바 아이콘 — 사진처럼 크게. 작으면 엄지로 겨냥하기도 어렵다 */
private val BarIconBox = 48.dp
private val BarIconSize = 28.dp

/** 같은 분류 안에서 몇 번째로 많이 봤는지. TODO(서버): 랭킹이 오면 지운다 */
private fun popularityRank(item: StoreItem): Int =
    storeItemPlaceholder
        .filter { it.category == item.category }
        .sortedByDescending { it.views }
        .indexOfFirst { it.id == item.id } + 1
