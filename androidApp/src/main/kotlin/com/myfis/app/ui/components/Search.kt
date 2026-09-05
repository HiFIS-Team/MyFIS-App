package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 검색 화면 공용 조각 (DESIGN.md §6.9).
 *
 * **검색은 잎 화면이다** — 장바구니(S-06)·알림(H-02)과 **똑같은 라우트**다.
 * 그래서 하단 탭 바를 통째로 덮는 것도, 옆에서 밀려 들어오는 것도 잎이 알아서 한다.
 *
 * 레퍼런스는 **당근 검색** 🟢 (2026-09-05, 사용자 지정) — 머리 한 줄에
 * `‹ 뒤로` · 필드 · `닫기` 가 나란히 서고, 아래는 **최근 검색**이다.
 */

/** `‹` + 필드 + `닫기`. **제목을 두지 않는다** — 필드가 곧 제목이다. */
@Composable
fun SearchHeader(
    query: String,
    onQuery: (String) -> Unit,
    placeholder: String,
    onBack: () -> Unit,
) {
    val close = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(
                start = MyFisSpacing.screenHorizontal - MyFisSpacing.sm,
                end = MyFisSpacing.screenHorizontal,
            ),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        HeaderIcon(R.drawable.ic_tab_back, "뒤로", onBack)

        SearchField(
            query = query,
            onQuery = onQuery,
            placeholder = placeholder,
            autoFocus = true,
            modifier = Modifier.weight(1f),
        )

        Text(
            "닫기",
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextSecondary,
            modifier = Modifier
                .clip(MyFisRadius.md)
                .tapWithHaptics(close, onBack)
                .padding(horizontal = MyFisSpacing.xs, vertical = MyFisSpacing.sm),
        )
    }
}

/**
 * 검색 입력칸 — 앱에 **하나뿐이다** (§6.9). 스토어·모임·지역이 같이 쓴다.
 * 값은 §6.9 그대로 — 높이 `40` · `surface.2` · `radius.md` · 돋보기 `20` · 문구 `body.sm`.
 */
@Composable
fun SearchField(
    query: String,
    onQuery: (String) -> Unit,
    placeholder: String,
    modifier: Modifier = Modifier,
    autoFocus: Boolean = false,
) {
    val clear = remember { MutableInteractionSource() }
    val focus = remember { FocusRequester() }

    LaunchedEffect(autoFocus) { if (autoFocus) focus.requestFocus() }

    Row(
        modifier = modifier
            .height(40.dp)
            // 누름 축소는 **아이콘에만** 준다 (§6.7). 판이 통째로 움찔거리면 화면이 흔들려 보인다
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
                Text(placeholder, style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
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
                modifier = Modifier.fillMaxWidth().focusRequester(focus),
            )
        }

        // 닫기가 옆에 있어도 지우개는 둔다 — 검색어만 바꿔 다시 치는 일이 더 잦다
        if (query.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(MyFisRadius.full)
                    .tapWithHaptics(clear) { onQuery("") },
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

/**
 * 최근 검색 + (아직 없으면) 추천 검색어.
 *
 * **빈 판을 두지 않는다** — 아직 아무것도 안 쳤을 때는 누를 거리를 준다.
 */
@Composable
fun SearchEmptyState(
    recents: List<String>,
    suggestions: List<String>,
    onPick: (String) -> Unit,
    onRemove: (String) -> Unit,
    onClearAll: () -> Unit,
) {
    if (recents.isEmpty()) {
        Column(
            Modifier.padding(top = MyFisSpacing.lg),
            verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            SectionTitle("추천 검색어", null)
            // TODO(서버): 추천 검색어는 서버가 고른다
            FlowRow(
                modifier = Modifier.padding(horizontal = MyFisSpacing.screenHorizontal),
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                suggestions.forEach { word ->
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
    } else {
        LazyColumn(contentPadding = PaddingValues(top = MyFisSpacing.lg, bottom = MyFisSpacing.xxxl)) {
            item {
                SectionTitle("최근 검색", onClearAll)
            }
            items(recents, key = { it }) { word ->
                RecentRow(word, onTap = { onPick(word) }, onRemove = { onRemove(word) })
            }
        }
    }
}

@Composable
private fun SectionTitle(title: String, onClearAll: (() -> Unit)?) {
    val clearAll = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal, vertical = 0.dp)
            .padding(bottom = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
        Box(Modifier.weight(1f))
        if (onClearAll != null) {
            Text(
                "전체 삭제",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                modifier = Modifier
                    .clip(MyFisRadius.md)
                    .tapWithHaptics(clearAll, onClearAll)
                    .padding(horizontal = MyFisSpacing.xs, vertical = MyFisSpacing.xs),
            )
        }
    }
}

/** 최근 검색 한 줄 — 시계 + 검색어 + `✕`. */
@Composable
private fun RecentRow(word: String, onTap: () -> Unit, onRemove: () -> Unit) {
    val row = remember { MutableInteractionSource() }
    val remove = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier.fillMaxWidth().height(MyFisSize.listRowMin),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            modifier = Modifier
                .weight(1f)
                .fillMaxSize()
                .tapWithHaptics(row, onTap)
                .padding(start = MyFisSpacing.screenHorizontal),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_time),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(20.dp),
            )
            Text(word, style = MyFisTheme.type.body, color = MyFisColor.TextPrimary)
        }

        Box(
            modifier = Modifier
                .size(MyFisSize.minTouchTarget)
                .clip(MyFisRadius.full)
                .tapWithHaptics(remove, onRemove),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_header_close),
                contentDescription = "$word 지우기",
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(16.dp),
            )
        }
        Box(Modifier.size(MyFisSpacing.screenHorizontal - MyFisSpacing.md))
    }
}

/** 걸린 게 없을 때 — 두 검색 화면이 같은 글을 쓴다. */
@Composable
fun SearchNoResult(query: String, onClear: () -> Unit) {
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

/**
 * 최근 검색 목록 — **셸이 들고 있다** (두 플랫폼 같다).
 * TODO(서버): 계정에 붙는다. 지금은 앱을 끄면 사라진다
 */
class SearchRecents(initial: List<String> = emptyList()) {
    // ⚠️ `mutableStateOf` 여야 목록이 바뀔 때 화면이 다시 그려진다
    var words by mutableStateOf(initial)
        private set

    /** 같은 말을 다시 치면 **맨 위로 올라온다**. 열 개까지만 둔다 */
    fun add(word: String) {
        val trimmed = word.trim()
        if (trimmed.isEmpty()) return
        words = (listOf(trimmed) + words.filter { it != trimmed }).take(10)
    }

    fun remove(word: String) { words = words.filter { it != word } }
    fun clear() { words = emptyList() }
}
