package com.myfis.app.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
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
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
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

    val scroll = rememberScrollState()
    // 이미지(정사각)를 지나면 아이콘 밑으로 **글자가 지나간다.** 그때부터 바탕을 깔아 준다
    val imageHeightPx = with(LocalDensity.current) {
        LocalConfiguration.current.screenWidthDp.dp.toPx()
    }
    val barAlpha by animateFloatAsState(
        targetValue = if (scroll.value > imageHeightPx - 160f) 1f else 0f,
        animationSpec = MyFisMotion.base(),
        label = "barAlpha",
    )

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase),
    ) {
        Box(Modifier.weight(1f)) {
            Column(Modifier.verticalScroll(scroll)) {
                ItemImage()
                ItemHead(item = item)
                ItemFacts(item = item)
                ItemReviews(item = item, reviews = storeReviewPlaceholder)
            }

            // **버튼은 스크롤을 따라가지 않는다.** 내려 읽다가 뒤로가기가 사라지면 안 된다
            Column(
                Modifier
                    .fillMaxWidth()
                    .background(MyFisColor.BgBase.copy(alpha = barAlpha)),
            ) {
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

/**
 * 분류·이름·가격.
 *
 * 이름과 가격을 **한 줄에 마주 세운다.** 가격을 왼쪽 아래에 따로 두면
 * 오른쪽이 통째로 비어 화면이 성겨 보인다.
 */
@Composable
private fun ItemHead(item: StoreItem) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(
                horizontal = MyFisSpacing.screenHorizontal,
                vertical = MyFisSpacing.lg,
            ),
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm)) {
            Chip(item.category.label, dot = categoryColor(item.category))
            // TODO: 분류 랭킹(🔵)이 붙으면 연결한다
            Chip("인기 ${popularityRank(item)}위", chevron = true)
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                item.name,
                style = MyFisTheme.type.titleLg,
                color = MyFisColor.TextPrimary,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f),
            )
            Spacer(Modifier.size(MyFisSpacing.md))
            Icon(
                painter = painterResource(R.drawable.ic_mileage_fill),
                contentDescription = null, // 옆 숫자가 이름 역할을 한다
                tint = MyFisColor.Accent,
                modifier = Modifier.size(22.dp),
            )
            Spacer(Modifier.size(MyFisSpacing.xs))
            // 이 화면의 **핵심 숫자**라 액센트를 쓴다 (§3.1). 잔액 띠와 반대인데,
            // 거기선 코인만 라임이라 값이 흰색이어야 무엇이 중요한지 갈렸다. 여기는 가격이 주인공이다
            Text(
                item.price.toMileage(),
                style = MyFisTheme.type.metricMd.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.Accent,
            )
        }
    }
}

/**
 * 분류 점 색 (§3.1 카테고리 팔레트).
 *
 * **점에만 칠한다.** 글자까지 칠하면 액션처럼 보이고, 팔레트 규칙(아이콘 전용)도 깨진다.
 */
private fun categoryColor(category: StoreCategory) = when (category) {
    StoreCategory.DRINK -> MyFisColor.CategoryBlue
    StoreCategory.CAFFEINE -> MyFisColor.CategoryGold
    StoreCategory.PROTEIN -> MyFisColor.CategoryViolet
    StoreCategory.GOODS -> MyFisColor.CategoryCoral
    StoreCategory.ALL -> MyFisColor.CategoryGray
}

@Composable
private fun Chip(label: String, dot: Color? = null, chevron: Boolean = false) {
    Row(
        modifier = Modifier
            .background(MyFisColor.Surface2, MyFisRadius.sm)
            .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.xs),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        if (dot != null) {
            Box(
                Modifier
                    .size(6.dp)
                    .background(dot, CircleShape),
            )
        }
        Text(label, style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
        if (chevron) {
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier
                    .size(14.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

/**
 * 나머지 사실들.
 *
 * **카드로 담는다.** 위아래 선만 그으면 표처럼 보인다 (§6.19 · 리뷰와 같은 판단).
 * 줄마다 아이콘을 둬 네 줄이 회색 덩어리로 뭉치지 않게 한다.
 */
@Composable
private fun ItemFacts(item: StoreItem) {
    Column(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .padding(vertical = MyFisSpacing.sm),
    ) {
        FactRow(
            R.drawable.ic_store_rating,
            "평점 · 리뷰",
            "%.1f".format(item.rating),
            sub = "(%,d)".format(item.reviewCount),
            // 별만 색을 가진다 — `rating` 은 상태가 아니라 평점 전용 색이다 (§3.1)
            iconTint = MyFisColor.Rating,
            chevron = true,
        )
        FactRow(R.drawable.ic_store_views, "조회", item.views.toViewCount())
        // TODO(서버): 지점은 선택한 지점을 따라간다
        FactRow(R.drawable.ic_header_branch, "수령", "강남점 데스크", chevron = true)
        FactRow(R.drawable.ic_my_coupon, "교환권", "발급 후 7일 안에 수령")
    }
}

@Composable
private fun FactRow(
    icon: Int,
    label: String,
    value: String,
    sub: String? = null,
    iconTint: Color = MyFisColor.TextTertiary,
    chevron: Boolean = false,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .then(if (chevron) Modifier.tapWithHaptics(interaction, {}) else Modifier)
            .padding(
                horizontal = MyFisSpacing.cardPadding,
                vertical = MyFisSpacing.md,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = null, // 옆 라벨이 이름 역할을 한다
            tint = iconTint,
            modifier = Modifier.size(18.dp),
        )
        Spacer(Modifier.size(MyFisSpacing.sm))
        // 라벨 폭을 고정해 값이 **세로로 정렬**된다. `평점 · 리뷰` 가 가장 길어 그 폭에 맞춘다
        Text(
            label,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            maxLines = 1,
            modifier = Modifier.width(76.dp),
        )
        Text(
            value,
            style = MyFisTheme.type.body.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
        if (sub != null) {
            Text(
                sub,
                style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(start = MyFisSpacing.xs),
            )
        }
        Spacer(Modifier.weight(1f))
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
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .padding(top = MyFisSpacing.xl, bottom = MyFisSpacing.md),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        Row(
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

        RatingSummary(item)

        reviews.forEach { ReviewCard(it) }

        // TODO: 전체 리뷰 목록(🔵)이 붙으면 연결한다
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(MyFisRadius.md)
                .tapWithHaptics(interaction, {})
                .padding(vertical = MyFisSpacing.md),
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

/**
 * 평균 별점 + 분포.
 *
 * **숫자를 주인공으로 세운다** (§2 원칙 1). 분포 막대는 회색으로 둔다 —
 * 별까지 금색, 막대까지 금색이면 요약이 시끄러워진다.
 */
@Composable
private fun RatingSummary(item: StoreItem) {
    val breakdown = remember(item.id) { item.ratingBreakdown() }
    val peak = (breakdown.maxOrNull() ?: 1).coerceAtLeast(1)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .padding(MyFisSpacing.cardPadding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Column(
            modifier = Modifier.padding(end = MyFisSpacing.lg),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(
                "%.1f".format(item.rating),
                style = MyFisTheme.type.metricLg.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
            )
            Stars(item.rating.toInt(), size = 16.dp)
        }

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(4.dp),
        ) {
            breakdown.forEachIndexed { index, count ->
                BreakdownRow(star = 5 - index, count = count, ratio = count.toFloat() / peak)
            }
        }
    }
}

@Composable
private fun BreakdownRow(star: Int, count: Int, ratio: Float) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Text(
            "$star",
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
        )
        Box(
            Modifier
                .weight(1f)
                .height(6.dp)
                .clip(MyFisRadius.full)
                .background(MyFisColor.Surface3),
        ) {
            Box(
                Modifier
                    .fillMaxWidth(ratio.coerceIn(0f, 1f))
                    .fillMaxHeight()
                    .clip(MyFisRadius.full)
                    .background(MyFisColor.TextSecondary),
            )
        }
        Text(
            "%,d".format(count),
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
            modifier = Modifier.size(width = 34.dp, height = 16.dp),
        )
    }
}

/** 리뷰 한 장. **구분선 대신 카드**로 나눈다 — 선을 그으면 목록이 표처럼 보인다 (§6.19 와 같은 판단) */
@Composable
private fun ReviewCard(review: StoreReview) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        Modifier
            .fillMaxWidth()
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .padding(MyFisSpacing.cardPadding),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Stars(review.rating, size = 14.dp)
            Text(review.author, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            Spacer(Modifier.weight(1f))
            Text(review.date, style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
        }

        Text(
            review.body,
            style = MyFisTheme.type.body,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )

        // TODO(서버): 도움 됐어요 집계가 붙으면 실제로 누르게 한다
        Row(
            modifier = Modifier
                .align(Alignment.End)
                .padding(top = MyFisSpacing.sm)
                .clip(MyFisRadius.full)
                .background(MyFisColor.Surface2)
                .tapWithHaptics(interaction, {})
                .padding(horizontal = MyFisSpacing.md, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_store_helpful),
                contentDescription = "도움 됐어요",
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(15.dp),
            )
            Text(
                "${review.helpful}",
                style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextSecondary,
            )
        }
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
