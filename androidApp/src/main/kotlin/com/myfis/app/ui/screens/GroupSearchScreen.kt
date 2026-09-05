package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
 * SPEC.md G-01 모임 검색 — 상품 검색(S-07)과 **같은 꼴의 잎 화면**이다.
 *
 * 모임 헤더의 돋보기로 들어온다. 전에는 그 돋보기가 **셸에 안 이어져 있어 눌러도 아무 일이 없었다**.
 */
@Composable
fun GroupSearchScreen(
    recents: SearchRecents,
    onBack: () -> Unit = {},
    onGroup: (GroupItem) -> Unit = {},
) {
    var query by rememberSaveable { mutableStateOf("") }

    /*
     * **이름 · 갈래 · 지역**으로 찾는다. 한 줄 소개는 안 본다 —
     * 문장까지 걸면 **왜 걸렸는지 줄만 봐서는 알 수 없는 결과**가 섞인다.
     * TODO(서버): 검색은 서버가 한다 (SPEC §8)
     */
    val results = remember(query) {
        groupPlaceholder.filter {
            it.name.contains(query, ignoreCase = true) ||
                it.category.label.contains(query, ignoreCase = true) ||
                it.region.contains(query, ignoreCase = true)
        }
    }

    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        SearchHeader(query, { query = it }, "모임 검색", onBack)

        when {
            query.isBlank() -> SearchEmptyState(
                recents = recents.words,
                suggestions = groupSearchWordPlaceholder,
                onPick = { query = it; recents.add(it) },
                onRemove = { recents.remove(it) },
                onClearAll = { recents.clear() },
            )
            results.isEmpty() -> SearchNoResult(query) { query = "" }
            else -> LazyColumn(
                contentPadding = PaddingValues(top = MyFisSpacing.md, bottom = MyFisSpacing.xxxl),
            ) {
                items(results, key = { it.id }) { group ->
                    GroupRow(group) { recents.add(query); onGroup(group) }
                }
            }
        }
    }
}

/**
 * TODO(서버): 추천 검색어 API 가 붙으면 지운다.
 * **다 걸리는 말로 골랐다** — 눌렀는데 결과가 없으면 추천이 아니다
 */
val groupSearchWordPlaceholder = listOf("러닝", "웨이트", "클래스", "등산", "치평동")
