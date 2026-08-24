package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-01 스토어 홈. (레퍼런스: 토스 쇼핑)
 *
 * 위에서부터 — 헤더(검색·장바구니·마이) · 카테고리 · 내 마일리지 · 배너 · 마일리지 모으기 · 상품 그리드.
 *
 * **레퍼런스의 구조만 가져오고 색은 우리 것을 쓴다** (DESIGN.md §3.2).
 * 원본은 파랑·빨강 뱃지가 화면마다 튀지만, 우리는 다크 + 라임 하나다.
 * 이 화면에서 **라임은 내 마일리지 숫자 한 곳뿐** — 상품 가격까지 라임으로 칠하면
 * "지금 중요한 숫자" 라는 신호가 사라진다.
 *
 * 헤더 위쪽(카테고리·마일리지)은 **스크롤해도 남는다** (S 공통 규칙 — 살 수 있는지 매번 계산하게 하지 않는다).
 */
@Composable
fun StoreScreen(
    onSearch: () -> Unit = {},
    onCart: () -> Unit = {},
    onMy: () -> Unit = {},
    onHistory: () -> Unit = {},
    onQuest: (StoreQuest) -> Unit = {},
    onItem: (StoreItem) -> Unit = {},
) {
    var category by rememberSaveable { mutableStateOf(StoreCategory.ALL) }
    val items = remember(category) {
        storeItemPlaceholder.filter { category == StoreCategory.ALL || it.category == category }
    }

    Column(Modifier.fillMaxSize()) {
        StoreHeader(onSearch = onSearch, onCart = onCart, onMy = onMy)
        CategoryTabs(selected = category, onSelect = { category = it })
        MileageStrip(balance = mileageBalancePlaceholder, onHistory = onHistory)

        LazyColumn(contentPadding = PaddingValues(bottom = MyFisSpacing.xxxl)) {
            item { BannerCarousel(storeBannerPlaceholder) }
            item { QuestSection(storeQuestPlaceholder, onQuest) }
            item {
                SectionHeader(
                    title = "추천 상품",
                    // 상품은 지점별로 다를 수 있다 (SPEC S-01) — 무엇이 걸러진 목록인지 밝힌다
                    chip = "내 지점",
                    modifier = Modifier.padding(top = MyFisSpacing.xxl),
                )
            }
            items(items.chunked(2)) { row ->
                ItemRow(row = row, balance = mileageBalancePlaceholder, onItem = onItem)
            }
        }
    }
}

/**
 * 스토어 헤더 (DESIGN.md §6.9).
 *
 * 검색이 폭을 다 먹고 오른쪽에 장바구니 · 마이만 둔다.
 * **워드마크를 넣지 않는다** — 검색이 들어오면 가운데 자리가 없다.
 */
@Composable
private fun StoreHeader(
    onSearch: () -> Unit,
    onCart: () -> Unit,
    onMy: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            // 아이콘의 터치 영역이 화면 여백만큼 튀어나오므로 그만큼 당겨 준다 (§6.9)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        SearchField(
            onClick = onSearch,
            modifier = Modifier
                .weight(1f)
                .padding(start = MyFisSpacing.sm, end = MyFisSpacing.xs),
        )
        HeaderIcon(R.drawable.ic_header_cart, "장바구니", onCart)
        HeaderIcon(R.drawable.ic_header_my, "마이", onMy)
    }
}

/**
 * 누르면 검색 화면으로 간다. 여기서 바로 입력받지 않는다 —
 * 헤더에서 키보드가 올라오면 목록이 반쯤 가린 채로 타이핑하게 된다.
 */
@Composable
private fun SearchField(onClick: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Row(
        modifier = modifier
            .height(40.dp)
            .graphicsLayer {
                scaleX = press
                scaleY = press
            }
            .background(MyFisColor.Surface2, MyFisRadius.full)
            .tapWithHaptics(interaction, onClick)
            .padding(horizontal = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_header_search),
            contentDescription = null, // 옆 문구가 이름 역할을 한다
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(20.dp),
        )
        Text("상품 검색", style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
    }
}

/** 카테고리 — 고른 것만 알약이 채워진다. 하단 탭·캘린더와 같은 규칙이다 (색이 아니라 채움) */
@Composable
private fun CategoryTabs(
    selected: StoreCategory,
    onSelect: (StoreCategory) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = MyFisSpacing.md),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        StoreCategory.entries.forEach { category ->
            val isSelected = category == selected
            val interaction = remember { MutableInteractionSource() }
            Box(
                modifier = Modifier
                    .clip(MyFisRadius.md)
                    .background(if (isSelected) MyFisColor.Surface2 else Color.Transparent)
                    .tapWithHaptics(interaction) { onSelect(category) }
                    .padding(horizontal = MyFisSpacing.md, vertical = 10.dp),
            ) {
                Text(
                    category.label,
                    style = MyFisTheme.type.titleSm,
                    color = if (isSelected) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                )
            }
        }
    }
}

/**
 * 보유 마일리지 — **스크롤해도 남는다** (SPEC S 공통 규칙).
 *
 * 이 화면의 라임은 여기 하나다.
 */
@Composable
private fun MileageStrip(balance: Int, onHistory: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("내 마일리지", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
        Text(
            balance.toMileage(),
            style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.Accent,
            modifier = Modifier.padding(start = MyFisSpacing.sm),
        )
        Spacer(Modifier.weight(1f))
        Text(
            "교환 내역 ›",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            modifier = Modifier
                .clip(MyFisRadius.full)
                .tapWithHaptics(interaction, onHistory)
                .padding(horizontal = MyFisSpacing.sm, vertical = MyFisSpacing.xs),
        )
    }
}

/** 배너 — 옆 장이 살짝 보이게 두고 넘긴다. 몇 장 중 몇 번째인지 오른쪽 아래에 적는다 */
@Composable
private fun BannerCarousel(banners: List<StoreBanner>, modifier: Modifier = Modifier) {
    val pager = rememberPagerState { banners.size }

    HorizontalPager(
        state = pager,
        contentPadding = PaddingValues(horizontal = MyFisSpacing.screenHorizontal),
        pageSpacing = MyFisSpacing.md,
        modifier = modifier.padding(top = MyFisSpacing.sm),
    ) { page ->
        val banner = banners[page]
        Box(
            Modifier
                .fillMaxWidth()
                .height(150.dp)
                .clip(MyFisRadius.lg)
                .background(MyFisColor.Surface1),
        ) {
            // 사진이 없으므로 우리 벡터를 크게 깔아 자리를 잡는다.
            // TODO(서버): 배너 이미지가 오면 교체한다.
            Icon(
                painter = painterResource(banner.icon),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier
                    .size(132.dp)
                    .align(Alignment.CenterEnd)
                    .offset(x = 18.dp),
            )
            Column(
                Modifier
                    .align(Alignment.CenterStart)
                    .padding(MyFisSpacing.cardPadding),
            ) {
                Text(banner.title, style = MyFisTheme.type.titleLg, color = MyFisColor.TextPrimary)
                Text(
                    banner.body,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextSecondary,
                    modifier = Modifier.padding(top = MyFisSpacing.sm),
                )
            }
            Text(
                "${page + 1} / ${banners.size}",
                style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextSecondary,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(MyFisSpacing.md)
                    .background(MyFisColor.Surface3, MyFisRadius.full)
                    .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
            )
        }
    }
}

/**
 * 마일리지 모으기 — 살 수 없는 걸 봤을 때 **바로 모으러 갈 수 있어야 한다.**
 * 혜택 탭(P)의 미니 활동으로 가는 지름길이다.
 */
@Composable
private fun QuestSection(
    quests: List<StoreQuest>,
    onQuest: (StoreQuest) -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier.padding(top = MyFisSpacing.xxl)) {
        SectionHeader(
            title = "마일리지 모으기",
            chip = "오늘 최대 ${quests.sumOf { it.reward }.toMileage()}",
        )
        LazyRow(
            contentPadding = PaddingValues(horizontal = MyFisSpacing.screenHorizontal),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
            modifier = Modifier.padding(top = MyFisSpacing.md),
        ) {
            items(quests) { quest -> QuestTile(quest, onClick = { onQuest(quest) }) }
        }
    }
}

@Composable
private fun QuestTile(quest: StoreQuest, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Column(
        modifier = Modifier
            .width(64.dp)
            .clip(MyFisRadius.md)
            .tapWithHaptics(interaction, onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(Modifier.height(66.dp), contentAlignment = Alignment.BottomCenter) {
            Box(
                Modifier
                    .size(56.dp)
                    .graphicsLayer {
                        scaleX = press
                        scaleY = press
                    }
                    .background(MyFisColor.Surface2, RoundedCornerShape(18.dp)),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(quest.icon),
                    contentDescription = null, // 라벨이 바로 아래 있다
                    tint = MyFisColor.TextPrimary,
                    modifier = Modifier.size(26.dp),
                )
            }
            // 뱃지는 타일 위로 떠서 걸친다 (레퍼런스와 같은 배치)
            Text(
                "+${quest.reward}P",
                style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .background(MyFisColor.Surface3, MyFisRadius.full)
                    .padding(horizontal = MyFisSpacing.sm, vertical = 1.dp),
            )
        }
        Text(
            quest.label,
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextSecondary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
    }
}

@Composable
private fun SectionHeader(title: String, chip: String? = null, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        if (chip != null) {
            Text(
                chip,
                style = MyFisTheme.type.caption,
                color = MyFisColor.TextSecondary,
                modifier = Modifier
                    .padding(start = MyFisSpacing.sm)
                    .background(MyFisColor.Surface2, MyFisRadius.full)
                    .padding(horizontal = MyFisSpacing.sm, vertical = 3.dp),
            )
        }
    }
}

@Composable
private fun ItemRow(row: List<StoreItem>, balance: Int, onItem: (StoreItem) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.sm),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        row.forEach { item ->
            ItemCard(item, balance, onClick = { onItem(item) }, modifier = Modifier.weight(1f))
        }
        // 홀수로 끝나면 왼쪽 카드가 폭을 다 먹지 않도록 빈자리를 남긴다
        if (row.size == 1) Spacer(Modifier.weight(1f))
    }
}

/**
 * 상품 카드.
 *
 * **부족해도 가리지 않는다** (SPEC S-01) — 얼마가 모자란지 적어 목표로 삼게 한다.
 * 품절도 숨기지 않는다.
 */
@Composable
private fun ItemCard(
    item: StoreItem,
    balance: Int,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()
    val short = (item.price - balance).coerceAtLeast(0)

    Column(
        modifier = modifier
            .clip(MyFisRadius.md)
            .tapWithHaptics(interaction, onClick),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .graphicsLayer {
                    scaleX = press
                    scaleY = press
                }
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2),
            contentAlignment = Alignment.Center,
        ) {
            // TODO(서버): 상품 이미지가 오면 교체한다. 지금은 자리만 잡는다.
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier.size(52.dp),
            )
            if (item.soldEnough(balance).not() || item.soldOut) {
                Text(
                    if (item.soldOut) "품절" else "${short.toMileage()} 부족",
                    style = MyFisTheme.type.caption,
                    color = if (item.soldOut) MyFisColor.TextSecondary else MyFisColor.TextTertiary,
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(MyFisSpacing.sm)
                        .background(MyFisColor.Surface3, MyFisRadius.sm)
                        .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
                )
            }
        }
        Text(
            item.name,
            style = MyFisTheme.type.bodySm,
            color = if (item.soldOut) MyFisColor.TextTertiary else MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        Text(
            item.price.toMileage(),
            style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
            color = if (item.soldOut) MyFisColor.TextTertiary else MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = 2.dp),
        )
    }
}

/** 지금 가진 마일리지로 바꿀 수 있나 */
private fun StoreItem.soldEnough(balance: Int): Boolean = price <= balance
