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
import androidx.compose.foundation.layout.height
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
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-07 상품 검색 (DESIGN.md §6.9).
 *
 * **검색은 화면을 띄운다** — 헤더의 검색 자리를 누르면 여기가 밀려 들어오고
 * **하단 탭까지 덮는다** (§7.1 잎 화면). 검색은 목록을 훑는 일과 다른 일이라 자리를 따로 준다.
 *
 * 들어오면 **키보드가 바로 올라온다.** 검색하러 들어온 사람에게 한 번 더 누르게 하지 않는다.
 */
@Composable
fun StoreSearchScreen(
    onBack: () -> Unit,
    onItem: (StoreItem) -> Unit = {},
    balance: Int = mileageBalancePlaceholder,
) {
    var query by rememberSaveable { mutableStateOf("") }
    var liked by rememberSaveable { mutableStateOf(setOf<Int>()) }
    val focus = remember { FocusRequester() }

    LaunchedEffect(Unit) { focus.requestFocus() }

    val results = storeItemPlaceholder.filter { it.name.contains(query, ignoreCase = true) }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        SearchBar(
            query = query,
            onQuery = { query = it },
            onBack = onBack,
            focus = focus,
        )

        when {
            query.isBlank() -> Suggestions(onPick = { query = it })
            results.isEmpty() -> EmptyResult(query = query, onClear = { query = "" })
            else -> Results(
                results = results,
                balance = balance,
                liked = liked,
                onLike = { id -> liked = if (id in liked) liked - id else liked + id },
                onItem = onItem,
            )
        }
    }
}

/** 뒤로 + 입력 필드. 헤더 자리를 필드가 다 쓴다 (§6.9) */
@Composable
private fun SearchBar(
    query: String,
    onQuery: (String) -> Unit,
    onBack: () -> Unit,
    focus: FocusRequester,
) {
    val backInteraction = remember { MutableInteractionSource() }
    val backPress by backInteraction.pressScale()
    val clearInteraction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .padding(horizontal = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            modifier = Modifier
                .size(44.dp)
                .clip(CircleShape)
                .tapWithHaptics(backInteraction, onBack),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_back),
                contentDescription = "뒤로",
                tint = MyFisColor.TextPrimary,
                modifier = Modifier
                    .size(24.dp)
                    .graphicsLayer {
                        scaleX = backPress
                        scaleY = backPress
                    },
            )
        }

        Row(
            modifier = Modifier
                .padding(start = MyFisSpacing.sm)
                .weight(1f)
                .height(40.dp)
                .background(MyFisColor.Surface2, MyFisRadius.md)
                .padding(horizontal = MyFisSpacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_header_search),
                contentDescription = null, // 옆 입력칸이 이름 역할을 한다
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(20.dp),
            )
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
