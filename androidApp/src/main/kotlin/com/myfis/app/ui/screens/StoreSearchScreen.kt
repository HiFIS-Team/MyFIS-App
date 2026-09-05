package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.myfis.app.ui.components.SearchEmptyState
import com.myfis.app.ui.components.SearchHeader
import com.myfis.app.ui.components.SearchNoResult
import com.myfis.app.ui.components.SearchRecents
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing

/**
 * SPEC.md S-07 상품 검색 — **잎 화면이다** 🟢 (2026-09-05, 사용자 지정).
 *
 * 장바구니(S-06)·알림(H-02)과 **똑같은 라우트**라 하단 탭 바를 통째로 덮는다.
 * 레퍼런스는 당근 검색 — 머리 한 줄에 `‹` · 필드 · `닫기`, 아래는 최근 검색이다 (§6.9).
 */
@Composable
fun StoreSearchScreen(
    liked: MutableMap<Int, Boolean>,
    recents: SearchRecents,
    onLike: (Int) -> Unit,
    onBack: () -> Unit = {},
    onItem: (StoreItem) -> Unit = {},
    balance: Int = mileageBalancePlaceholder,
) {
    var query by rememberSaveable { mutableStateOf("") }
    val results = remember(query) {
        storeItemPlaceholder.filter { it.name.contains(query, ignoreCase = true) }
    }

    Column(
        Modifier
            .fillMaxSize()
            // ⚠️ **잎은 자기 배경을 칠한다** — 안 칠하면 밀려 들어오는 동안 뒤 화면이 비친다
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        SearchHeader(query, { query = it }, "상품 검색", onBack)

        when {
            query.isBlank() -> SearchEmptyState(
                recents = recents.words,
                suggestions = storeSearchWordPlaceholder,
                onPick = { query = it; recents.add(it) },
                onRemove = { recents.remove(it) },
                onClearAll = { recents.clear() },
            )
            results.isEmpty() -> SearchNoResult(query) { query = "" }
            else -> LazyVerticalGrid(
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
                        liked = liked[item.id] == true,
                        onLike = { onLike(item.id) },
                        onClick = { recents.add(query); onItem(item) },
                    )
                }
            }
        }
    }
}

/** TODO(서버): 추천 검색어 API 가 붙으면 지운다 */
val storeSearchWordPlaceholder = listOf("음료", "프로틴", "타월", "보틀", "매트")
