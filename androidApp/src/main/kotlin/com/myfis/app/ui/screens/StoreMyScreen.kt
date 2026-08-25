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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MileageBand
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisGhostButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-08 스토어 마이 (DESIGN.md §6.20).
 *
 * **마이 탭(Y-01)과 다른 화면이다.** 여기는 스토어 안에서의 나 —
 * 교환권(S-04) · 교환 내역(S-05) · 장바구니(S-06) 처럼 **교환에 관한 것만** 모인다.
 * 프로필·기록·설정은 마이 탭이 맡는다.
 *
 * 스토어 헤더에서 **오른쪽에서 왼쪽으로 밀려 들어온다** (잎 화면, DESIGN.md §7.1).
 */
@Composable
fun StoreMyScreen(onBack: () -> Unit, onCart: () -> Unit = {}) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader("내 교환", onBack, actionIcon = R.drawable.ic_header_cart, onAction = onCart)

        Column(
            Modifier
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            // 스토어(§6.12)와 **같은 마일리지 표기**를 쓴다. 화면마다 다르면 같은 값으로 안 읽힌다
            MileageBand(balance = mileageBalancePlaceholder)
            QuickMenu(modifier = Modifier.padding(top = MyFisSpacing.md))
            RecentRow(count = 3, modifier = Modifier.padding(top = MyFisSpacing.cardGap))
            ExchangeCard(
                exchange = exchangePlaceholder,
                modifier = Modifier.padding(top = MyFisSpacing.cardGap),
            )
            InviteRow(modifier = Modifier.padding(top = MyFisSpacing.cardGap))
            SuggestionGrid(
                items = affordableForMyPlaceholder(mileageBalancePlaceholder),
                modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
            )
        }
    }
}

/** 네 갈래 바로가기. **네 개로 고정한다** — 다섯 개가 되면 한 줄에 안 들어가 글자가 줄어든다 */
@Composable
private fun QuickMenu(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .padding(vertical = MyFisSpacing.lg),
    ) {
        // TODO: 각 화면(S-04 · S-07 찜 · S-05 · 문의)이 붙으면 연결한다
        QuickItem(R.drawable.ic_my_coupon, "교환권", Modifier.weight(1f))
        QuickItem(R.drawable.ic_store_like_fill, "찜", Modifier.weight(1f))
        QuickItem(R.drawable.ic_quest_board, "교환 내역", Modifier.weight(1f))
        QuickItem(R.drawable.ic_my_ask, "문의", Modifier.weight(1f))
    }
}

@Composable
private fun QuickItem(icon: Int, label: String, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        modifier = modifier.tapWithHaptics(interaction, {}),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = null, // 밑 글자가 이름 역할을 한다
            tint = MyFisColor.TextPrimary,
            modifier = Modifier.size(26.dp),
        )
        Text(label, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
    }
}

/** 최근 본 상품 — 썸네일만 겹쳐 보여 주고 목록은 눌러서 본다 */
@Composable
private fun RecentRow(count: Int, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            // TODO: 최근 본 상품 목록이 붙으면 연결한다
            .tapWithHaptics(interaction, {})
            .padding(MyFisSpacing.cardPadding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("최근 본 상품", style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
            repeat(count) { Thumbnail(size = 36.dp) }
        }
        Chevron(Modifier.padding(start = MyFisSpacing.sm))
    }
}

/**
 * 교환 한 건 (DESIGN.md §6.20).
 *
 * 상태와 기한이 맨 위, 상품이 가운데, 할 수 있는 일이 맨 아래.
 * **기한이 제목보다 먼저 읽혀야 한다** — 교환권은 지나면 사라진다.
 */
@Composable
private fun ExchangeCard(exchange: MyExchange, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(MyFisSpacing.cardPadding),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(exchange.status, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
            Text(
                exchange.deadline,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(start = MyFisSpacing.sm),
            )
            Spacer(Modifier.weight(1f))
            MyFisSmallButton("교환권 보기", onClick = {})
        }

        Box(
            Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(MyFisColor.BorderSubtle),
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(MyFisSpacing.cardPadding),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            Thumbnail(size = 64.dp)
            Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                Text(
                    exchange.date,
                    style = MyFisTheme.type.caption,
                    color = MyFisColor.TextTertiary,
                )
                Text(
                    exchange.item,
                    style = MyFisTheme.type.body,
                    color = MyFisColor.TextPrimary,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Text(
                    "${exchange.price.toMileage()} · ${exchange.count}개",
                    style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                    color = MyFisColor.TextSecondary,
                )
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    start = MyFisSpacing.cardPadding,
                    end = MyFisSpacing.cardPadding,
                    bottom = MyFisSpacing.cardPadding,
                ),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            // TODO: 문의(🔵) · 리뷰(🔵) 화면이 붙으면 연결한다.
            // 리뷰가 우리가 바라는 행동이라 Secondary, 문의는 Ghost (§6.1)
            MyFisGhostButton("문의하기", onClick = {}, modifier = Modifier.weight(1f))
            MyFisSecondaryButton("리뷰 쓰기", onClick = {}, modifier = Modifier.weight(1f))
        }
    }
}

/** 친구 초대 — 마일리지가 늘어나는 유일한 '내가 하는' 길이라 이 화면에 둔다 */
@Composable
private fun InviteRow(modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            // TODO: 초대 링크 공유가 붙으면 연결한다
            .tapWithHaptics(interaction, {})
            .padding(MyFisSpacing.cardPadding),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("친구 초대", style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        Text(
            "1,000 P 받는 링크 보내기",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
        )
        Chevron(Modifier.padding(start = MyFisSpacing.xs))
    }
}

/** 잔액으로 바꿀 수 있는 것들. 홈(§6.16)과 같은 기준이라 여기서도 **부족한 상품은 넣지 않는다** */
@Composable
private fun SuggestionGrid(items: List<StoreItem>, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        Text("바꿀 만한 것", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Text(
            "지금 마일리지로 바로 교환할 수 있어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            modifier = Modifier.padding(top = 2.dp),
        )
        Spacer(Modifier.height(MyFisSpacing.md))

        items.chunked(2).forEach { row ->
            Row(
                modifier = Modifier.padding(bottom = MyFisSpacing.lg),
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
            ) {
                row.forEach { item ->
                    SuggestionCard(item, Modifier.weight(1f))
                }
                if (row.size == 1) Spacer(Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun SuggestionCard(item: StoreItem, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(modifier = modifier.tapWithHaptics(interaction, {})) {
        Box(
            Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2),
            contentAlignment = Alignment.Center,
        ) {
            // TODO(서버): 상품 이미지가 오면 교체한다
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier.size(44.dp),
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

/** 상품 자리값. TODO(서버): 이미지가 오면 교체한다 */
@Composable
private fun Thumbnail(size: androidx.compose.ui.unit.Dp) {
    Box(
        Modifier
            .size(size)
            .clip(MyFisRadius.sm)
            .background(MyFisColor.Surface2),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_tab_store),
            contentDescription = null,
            tint = MyFisColor.Surface3,
            modifier = Modifier.size(size / 2),
        )
    }
}

@Composable
private fun Chevron(modifier: Modifier = Modifier) {
    Icon(
        painter = painterResource(R.drawable.ic_chevron_down),
        contentDescription = null,
        tint = MyFisColor.TextTertiary,
        modifier = modifier
            .size(18.dp)
            .graphicsLayer { rotationZ = -90f },
    )
}

/** TODO(서버): 교환 내역 API 가 붙으면 지운다 (SPEC S-05) */
private data class MyExchange(
    val status: String,
    val deadline: String,
    val date: String,
    val item: String,
    val price: Int,
    val count: Int,
)

/** TODO(서버): 교환 API 가 붙으면 지운다 */
private val exchangePlaceholder = MyExchange(
    status = "수령 대기",
    deadline = "내일 23:59까지",
    date = "8월 24일 교환",
    item = "이온음료 500ml",
    price = 300,
    count = 1,
)

/** TODO(서버): 추천은 서버가 고른다. 홈(§6.16)과 같은 기준을 쓴다 */
private fun affordableForMyPlaceholder(balance: Int): List<StoreItem> =
    storeItemPlaceholder
        .filter { !it.soldOut && it.price <= balance }
        .sortedByDescending { it.views }
        .take(4)
