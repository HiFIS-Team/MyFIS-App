package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.StoreSearchShell
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
 *
 * **검색은 화면이 아니라 스토어의 모드다** 🟢 (2026-08-26) — 헤더의 검색 자리를 누르면
 * 그 자리에서 필드가 장바구니 자리까지 늘어나고, 마이가 `X` 로 바뀌고, 본문만 검색으로 바뀐다.
 * 화면이 옆에서 밀려 들어오지 않는다 — **검색은 다른 데로 가는 일이 아니라 지금 화면을 좁히는 일**이다.
 *
 * 여기에는 필드(`StoreSearchInput`)와 본문(`StoreSearchBody`)만 있다. 헤더는 스토어가 그린다.
 *
 * 열면 **키보드가 바로 올라온다.** 검색하러 누른 사람에게 한 번 더 누르게 하지 않는다.
 *
 * 본문 — 추천 검색어 · 결과 · 결과 없음.
 */
@Composable
fun StoreSearchBody(
    query: String,
    onQuery: (String) -> Unit,
    liked: Set<Int>,
    onLike: (Int) -> Unit,
    onItem: (StoreItem) -> Unit,
    balance: Int = mileageBalancePlaceholder,
) {
    val results = storeItemPlaceholder.filter { it.name.contains(query, ignoreCase = true) }

    when {
        query.isBlank() -> Suggestions(onPick = onQuery)
        results.isEmpty() -> EmptyResult(query = query, onClear = { onQuery("") })
        else -> Results(
            results = results,
            balance = balance,
            liked = liked,
            onLike = onLike,
            onItem = onItem,
        )
    }
}

/** 검색 입력 필드. 헤더에서 **장바구니 자리까지 늘어난다** (§6.9) */
@Composable
fun StoreSearchInput(
    query: String,
    onQuery: (String) -> Unit,
    focus: FocusRequester,
    modifier: Modifier = Modifier,
) {
    val clearInteraction = remember { MutableInteractionSource() }

    StoreSearchShell(modifier = modifier) {
        Box(Modifier.weight(1f), contentAlignment = Alignment.CenterStart) {
            if (query.isEmpty()) {
                Text(
                    "상품 검색",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextTertiary,
                )
            }
            BasicTextField(
                value = query,
                onValueChange = onQuery,
                singleLine = true,
                textStyle = LocalTextStyle.current.merge(
                    MyFisTheme.type.bodySm.copy(color = MyFisColor.TextPrimary),
                ),
                cursorBrush = SolidColor(MyFisColor.Accent),
                keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                modifier = Modifier
                    .fillMaxWidth()
                    .focusRequester(focus),
            )
        }
        if (query.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .tapWithHaptics(clearInteraction) { onQuery("") },
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    painter = painterResource(R.drawable.ic_header_clear),
                    contentDescription = "지우기",
                    tint = MyFisColor.TextTertiary,
                    modifier = Modifier.size(18.dp),
                )
            }
        }
    }
}

/** 빈 화면을 두지 않는다 — 아직 아무것도 안 쳤을 때는 **누를 거리**를 준다 */
@Composable
private fun Suggestions(onPick: (String) -> Unit) {
    Column(
        Modifier.padding(
            horizontal = MyFisSpacing.screenHorizontal,
            vertical = MyFisSpacing.lg,
        ),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        Text("추천 검색어", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm)) {
            // TODO(서버): 추천 검색어는 서버가 고른다
            searchSuggestionPlaceholder.forEach { word ->
                val interaction = remember(word) { MutableInteractionSource() }
                Text(
                    word,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextPrimary,
                    modifier = Modifier
                        .clip(MyFisRadius.full)
                        .background(MyFisColor.Surface2)
                        .tapWithHaptics(interaction) { onPick(word) }
                        .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
                )
            }
        }
    }
}

@Composable
private fun EmptyResult(query: String, onClear: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(
            "‘$query’ 검색 결과가 없어요",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextSecondary,
        )
        Text(
            "검색어 지우기",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            modifier = Modifier
                .padding(top = MyFisSpacing.md)
                .clip(MyFisRadius.md)
                .tapWithHaptics(interaction, onClear)
                .padding(horizontal = MyFisSpacing.md, vertical = MyFisSpacing.sm),
        )
    }
}

@Composable
private fun Results(
    results: List<StoreItem>,
    balance: Int,
    liked: Set<Int>,
    onLike: (Int) -> Unit,
    onItem: (StoreItem) -> Unit,
) {
    LazyVerticalGrid(
        columns = GridCells.Fixed(2),
        contentPadding = PaddingValues(
            start = MyFisSpacing.screenHorizontal,
            end = MyFisSpacing.screenHorizontal,
            top = MyFisSpacing.lg,
            bottom = MyFisSpacing.xxxl,
        ),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg),
    ) {
        items(results, key = { it.id }) { item ->
            ItemCard(
                item = item,
                balance = balance,
                liked = item.id in liked,
                onLike = { onLike(item.id) },
                onClick = { onItem(item) },
            )
        }
    }
}

/** TODO(서버): 추천 검색어 API 가 붙으면 지운다 */
val searchSuggestionPlaceholder = listOf("음료", "프로틴", "타월", "보틀", "매트")
