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
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
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
        // 제목은 헤더가 아니라 본문 맨 위에 크게 둔다 — 스크롤하면 같이 올라간다
        DetailHeader(null, onBack, actionIcon = R.drawable.ic_header_cart, onAction = onCart)

        Column(
            Modifier
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            TitleRow(balance = mileageBalancePlaceholder)
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

/** 화면 제목 + 보유 마일리지. 제목 옆이 **이 화면에서 가장 중요한 숫자** 자리다 */
@Composable
private fun TitleRow(balance: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("내 교환", style = MyFisTheme.type.titleLg, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        Row(
            modifier = Modifier
                .background(MyFisColor.Surface2, MyFisRadius.full)
                .padding(start = MyFisSpacing.sm, end = MyFisSpacing.md, top = 6.dp, bottom = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_mileage_fill),
                contentDescription = null, // 옆 숫자가 이름 역할을 한다
                tint = MyFisColor.Accent,
                modifier = Modifier.size(20.dp),
            )
            Text(
                balance.toMileage(),
                style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextPrimary,
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
            SmallButton("교환권 보기", onClick = {})
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
            // TODO: 문의(🔵) · 리뷰(🔵) 화면이 붙으면 연결한다
            WideButton("문의하기", accent = false, modifier = Modifier.weight(1f))
            WideButton("리뷰 쓰기", accent = true, modifier = Modifier.weight(1f))
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

/** 카드 안 작은 보조 버튼 */
@Composable
private fun SmallButton(label: String, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Text(
        label,
        style = MyFisTheme.type.bodySm,
        color = MyFisColor.TextSecondary,
        modifier = Modifier
            .clip(MyFisRadius.sm)
            .background(MyFisColor.Surface2)
            .tapWithHaptics(interaction, onClick)
            .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
    )
}

/** 카드 아래 나란한 두 버튼. 액센트는 **하나만** 준다 (§2 원칙 5) */
@Composable
private fun WideButton(label: String, accent: Boolean, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Box(
        modifier = modifier
            .clip(MyFisRadius.sm)
            .background(
                if (accent) MyFisColor.Accent.copy(alpha = 0.14f) else MyFisColor.Surface2,
            )
            .tapWithHaptics(interaction, {})
            .padding(vertical = MyFisSpacing.md),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            label,
            style = MyFisTheme.type.bodySm,
            color = if (accent) MyFisColor.Accent else MyFisColor.TextSecondary,
        )
    }
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
