package com.myfis.app.ui.screens

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.LinearOutSlowInEasing
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsDraggedAsState
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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.layout.positionInRoot
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.myfis.app.R
import com.myfis.app.ui.components.BurstRing
import com.myfis.app.ui.components.MileageBand
import com.myfis.app.ui.components.MileageText
import com.myfis.app.ui.components.MileageTone
import com.myfis.app.ui.components.rememberBurst
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.components.StoreSearchShell
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

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
    searching: Boolean,
    onSearching: (Boolean) -> Unit,
    onCart: () -> Unit = {},
    onMy: () -> Unit = {},
    onItem: (StoreItem) -> Unit = {},
) {
    var category by rememberSaveable { mutableStateOf(StoreCategory.ALL) }
    var query by rememberSaveable { mutableStateOf("") }
    // TODO(서버): 찜은 계정에 붙는다. 지금은 화면이 들고 있다
    val liked = remember { mutableStateMapOf<Int, Boolean>() }
    val items = remember(category) {
        storeItemPlaceholder.filter { category == StoreCategory.ALL || it.category == category }
    }
    val focus = remember { FocusRequester() }

    // 열면 바로 칠 수 있어야 한다 — 검색하러 누른 사람에게 한 번 더 누르게 하지 않는다
    LaunchedEffect(searching) { if (searching) focus.requestFocus() }

    Column(Modifier.fillMaxSize()) {
        StoreHeader(
            searching = searching,
            query = query,
            onQuery = { query = it },
            focus = focus,
            onSearch = { onSearching(true) },
            // 닫으면 검색어도 지운다 — 다음에 열었을 때 지난 검색어를 지우는 일부터 하게 된다
            onClose = {
                query = ""
                onSearching(false)
            },
            onCart = onCart,
            onMy = onMy,
        )

        if (searching) {
            StoreSearchBody(
                query = query,
                onQuery = { query = it },
                liked = liked.filterValues { it }.keys,
                onLike = { id -> liked[id] = liked[id] != true },
                onItem = onItem,
            )
            return@Column
        }

        MileageBand(balance = mileageBalancePlaceholder)

        LazyColumn(contentPadding = PaddingValues(bottom = MyFisSpacing.xxxl)) {
            item { BannerCarousel(storeBannerPlaceholder) }
            // 필터는 **위에 붙는다.** 목록을 내려가다 카테고리를 바꾸려고 위로 되돌아가면 안 된다
            stickyHeader {
                CategoryFilter(selected = category, onSelect = { category = it })
            }
            items(items.chunked(2)) { row ->
                ItemRow(
                    row = row,
                    balance = mileageBalancePlaceholder,
                    liked = liked,
                    onLike = { id -> liked[id] = liked[id] != true },
                    onItem = onItem,
                )
            }
        }
    }
}

/**
 * 스토어 헤더 (DESIGN.md §6.9).
 *
 * 검색이 폭을 다 먹고 오른쪽에 장바구니 · 마이만 둔다.
 * **워드마크를 넣지 않는다** — 검색이 들어오면 가운데 자리가 없다.
 *
 * 검색을 누르면 **이 자리에서 그대로 바뀐다** — 필드가 장바구니 자리까지 늘어나고
 * 마이가 `X` 가 된다. 화면이 옆에서 밀려 들어오지 않는다.
 */
@Composable
private fun StoreHeader(
    searching: Boolean,
    query: String,
    onQuery: (String) -> Unit,
    focus: FocusRequester,
    onSearch: () -> Unit,
    onClose: () -> Unit,
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
        // 왼쪽은 헤더 여백까지 그대로 쓴다. 여백을 더 주면 필드만 안쪽으로 밀려 짧아 보인다
        val field = Modifier
            .weight(1f)
            .padding(end = MyFisSpacing.xs)

        if (searching) {
            StoreSearchInput(query = query, onQuery = onQuery, focus = focus, modifier = field)
            HeaderIcon(R.drawable.ic_header_close, "검색 닫기", onClose)
        } else {
            SearchField(onClick = onSearch, modifier = field)
            HeaderIcon(R.drawable.ic_header_cart, "장바구니", onCart)
            HeaderIcon(R.drawable.ic_header_my, "마이", onMy)
        }
    }
}

/** 누르면 **이 자리가 입력 필드로 바뀐다** (§6.9). 화면이 따로 뜨지 않는다 */
@Composable
private fun SearchField(onClick: () -> Unit, modifier: Modifier = Modifier) {
    // 판은 검색 모드와 **같은 것**을 쓴다 (§6.9). 전에는 여기서 따로 그렸다 (2026-08-27 이관)
    StoreSearchShell(modifier = modifier, onClick = onClick) {
        Text("상품 검색", style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
    }
}

/**
 * 배너 — 옆 장이 살짝 보이게 두고 넘긴다. 몇 장 중 몇 번째인지 오른쪽 아래에 적는다.
 *
 * **5초마다 저절로 넘어가고, 끝에서 되감지 않는다.** 페이지를 사실상 무한히 두고
 * 나머지 연산으로 배너를 고르면 계속 같은 방향으로 흐른다 — 마지막에서 처음으로 되튀면
 * 눈에 걸린다.
 *
 * **손을 대면 멈춘다.** 떼고 나서 다시 5초를 센다 (읽는 중에 넘어가면 안 된다).
 */
@Composable
private fun BannerCarousel(banners: List<StoreBanner>, modifier: Modifier = Modifier) {
    val pageCount = Int.MAX_VALUE
    // 뒤로도 넘길 수 있게 한가운데서 시작한다. 배너 개수의 배수로 맞춰야 첫 장이 첫 배너다
    val startPage = remember(banners.size) { pageCount / 2 - (pageCount / 2) % banners.size }
    val pager = rememberPagerState(initialPage = startPage) { pageCount }

    val dragged by pager.interactionSource.collectIsDraggedAsState()
    // settledPage 가 바뀔 때마다 타이머를 다시 센다 — 손으로 넘긴 직후에도 5초를 새로 센다
    LaunchedEffect(dragged, pager.settledPage) {
        if (dragged) return@LaunchedEffect
        delay(BannerAutoScrollMillis)
        pager.animateScrollToPage(
            page = pager.currentPage + 1,
            animationSpec = tween(durationMillis = 320, easing = MyFisMotion.easing),
        )
    }

    HorizontalPager(
        state = pager,
        contentPadding = PaddingValues(horizontal = MyFisSpacing.screenHorizontal),
        pageSpacing = MyFisSpacing.md,
        modifier = modifier.padding(top = MyFisSpacing.sm),
    ) { page ->
        val index = page % banners.size
        val banner = banners[index]
        Box(
            Modifier
                .fillMaxWidth()
                .height(BannerHeight)
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
                    .size(144.dp)
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
                "${index + 1} / ${banners.size}",
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

private val BannerHeight = 168.dp
private const val BannerAutoScrollMillis = 5_000L

/**
 * 카테고리 필터 (레퍼런스: 무신사 탭).
 *
 * 알약이 아니라 **글자 + 밑줄**이다. 상품 목록 위에서는 알약이 시각적으로 너무 무겁고,
 * 여기서 고른 것은 "지금 보고 있는 목록"이라 제목처럼 읽혀야 한다.
 *
 * 밑줄은 칸을 따라 **흐른다** — 하단 탭·캘린더와 같은 규칙이다.
 */
@Composable
private fun CategoryFilter(
    selected: StoreCategory,
    onSelect: (StoreCategory) -> Unit,
    modifier: Modifier = Modifier,
) {
    val density = LocalDensity.current
    // 밑줄을 그리려면 고른 글자가 **어디서 시작해 얼마나 넓은지**를 알아야 한다.
    // 스크롤하면 위치가 바뀌므로 화면 기준으로 재고 컨테이너 기준으로 환산한다.
    var containerX by remember { mutableFloatStateOf(0f) }
    val bars = remember { mutableStateMapOf<StoreCategory, Pair<Float, Float>>() }
    val bar = bars[selected]
    // 고르는 동작이라 `fast`(120ms) 다. `base`(200ms) 는 감속 커브 때문에 끝이 끌린다
    val barX by animateDpAsState(
        with(density) { (bar?.first ?: 0f).toDp() }, MyFisMotion.fast(), label = "barX",
    )
    val barWidth by animateDpAsState(
        with(density) { (bar?.second ?: 0f).toDp() }, MyFisMotion.fast(), label = "barWidth",
    )

    Box(
        modifier = modifier
            .fillMaxWidth()
            // 스티키 헤더라 배경이 불투명해야 아래 카드가 비쳐 지나가지 않는다
            .background(MyFisColor.BgBase)
            .onGloballyPositioned { containerX = it.positionInRoot().x },
    ) {
        Row(
            Modifier
                .horizontalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        ) {
            StoreCategory.entries.forEach { entry ->
                val isSelected = entry == selected
                val interaction = remember { MutableInteractionSource() }
                Text(
                    entry.label,
                    style = MyFisTheme.type.titleSm.copy(
                        fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                    ),
                    color = if (isSelected) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                    modifier = Modifier
                        .tapWithHaptics(interaction) { onSelect(entry) }
                        .padding(horizontal = MyFisSpacing.sm, vertical = 12.dp)
                        .onGloballyPositioned { coords ->
                            bars[entry] = (coords.positionInRoot().x - containerX) to coords.size.width.toFloat()
                        },
                )
            }
        }

        Box(
            Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )
        Box(
            Modifier
                .align(Alignment.BottomStart)
                .offset(x = barX)
                .width(barWidth)
                .height(2.dp)
                .background(MyFisColor.TextPrimary),
        )
    }
}

@Composable
private fun ItemRow(
    row: List<StoreItem>,
    balance: Int,
    liked: Map<Int, Boolean>,
    onLike: (Int) -> Unit,
    onItem: (StoreItem) -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.sm),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        row.forEach { item ->
            ItemCard(
                item = item,
                balance = balance,
                liked = liked[item.id] == true,
                onLike = { onLike(item.id) },
                onClick = { onItem(item) },
                modifier = Modifier.weight(1f),
            )
        }
        // 홀수로 끝나면 왼쪽 카드가 폭을 다 먹지 않도록 빈자리를 남긴다
        if (row.size == 1) Spacer(Modifier.weight(1f))
    }
}

/**
 * 상품 카드 (레퍼런스: 토스 쇼핑).
 *
 * **카드 높이는 모두 같다.** 원본은 제목 줄 수에 따라 카드가 들쭉날쭉한데,
 * 그러면 그리드가 어긋나 보인다 — 제목을 **두 줄로 고정**해 자리를 미리 잡아 둔다.
 *
 * 제목과 마일리지 사이에 **몇 명이 봤는지 · 평점(리뷰 수)** 을 둔다.
 * 배송 문구(내일도착 같은 것)는 없다 — 여기 상품은 **지점에서 받는다.**
 *
 * **부족해도 가리지 않는다** (SPEC S-01) — 얼마가 모자란지 적어 목표로 삼게 한다. 품절도 마찬가지다.
 */
@Composable
fun ItemCard(
    item: StoreItem,
    balance: Int,
    liked: Boolean,
    onLike: () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val short = (item.price - balance).coerceAtLeast(0)
    val dimmed = item.soldOut

    Column(
        // 누름 축소는 **아이콘에만** 준다 (§6.7). 카드가 통째로 움찔거리면 그리드가 흔들려 보인다
        modifier = modifier
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .tapWithHaptics(interaction, onClick),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
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
            if (item.soldOut || short > 0) {
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

        Column(Modifier.padding(MyFisSpacing.md)) {
            Text(
                item.name,
                // 행간은 토큰(24)보다 좁힌다 — 두 줄을 미리 잡아 두므로 그대로 두면 제목 아래가 휑하다
                style = MyFisTheme.type.body.copy(lineHeight = 20.sp),
                color = if (dimmed) MyFisColor.TextTertiary else MyFisColor.TextPrimary,
                // 두 줄로 고정해야 카드 높이가 서로 같다
                minLines = 2,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            MetaRow(item, Modifier.padding(top = 2.dp))
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = MyFisSpacing.sm),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                MileageText(
                    item.price,
                    style = MyFisTheme.type.titleSm,
                    tone = if (dimmed) MileageTone.Dimmed else MileageTone.Primary,
                )
                Spacer(Modifier.weight(1f))
                LikeButton(liked = liked, onClick = onLike)
            }
        }
    }
}

/** 몇 명이 봤는지 · 평점(리뷰 수) — 제목과 가격 사이 */
@Composable
private fun MetaRow(item: StoreItem, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(3.dp),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_store_views),
            contentDescription = null,
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(13.dp),
        )
        Text(
            item.views.toViewCount(),
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
        )
        // 구분은 점이 아니라 **세로선**이다. 점은 조회수 숫자에 묻힌다
        Box(
            Modifier
                .padding(horizontal = 2.dp)
                .size(width = 1.dp, height = 10.dp)
                .background(MyFisColor.BorderStrong),
        )
        Icon(
            painter = painterResource(R.drawable.ic_store_rating),
            contentDescription = null,
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(11.dp),
        )
        Text(
            "%.1f (%,d)".format(item.rating, item.reviewCount),
            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
    }
}

/** 찜. 카드 전체를 누르면 상세로 가므로 여기만 따로 눌리게 한다 */
@Composable
fun LikeButton(
    liked: Boolean,
    onClick: () -> Unit,
    /** 터치 영역. 상세 화면의 하단 바처럼 크게 써야 하는 자리가 있다 */
    box: Dp = 28.dp,
    icon: Dp = 20.dp,
) {
    val interaction = remember { MutableInteractionSource() }
    // 튀고 고리가 퍼지는 반응은 리뷰의 `도움 됐어요` 와 **같은 것**을 쓴다 (§6.21)
    val burst = rememberBurst(liked)

    Box(
        modifier = Modifier
            .size(box)
            .clip(MyFisRadius.full)
            .tapWithHaptics(interaction, onClick),
        contentAlignment = Alignment.Center,
    ) {
        BurstRing(burst.ring, MyFisColor.Like, Modifier.matchParentSize())

        Icon(
            painter = painterResource(
                if (liked) R.drawable.ic_store_like_fill else R.drawable.ic_store_like,
            ),
            contentDescription = if (liked) "찜 해제" else "찜하기",
            tint = if (liked) MyFisColor.Like else MyFisColor.TextTertiary,
            modifier = Modifier
                .size(icon)
                .graphicsLayer {
                    scaleX = burst.pop
                    scaleY = burst.pop
                },
        )
    }
}


