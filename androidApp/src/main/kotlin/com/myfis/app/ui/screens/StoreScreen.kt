package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.shell.PlaceholderScreen
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md S-01 스토어 홈. (레퍼런스: 무신사)
 *
 * 홈과 헤더가 다르다 — 스토어에서 필요한 건 지점·알림이 아니라 **검색 · 장바구니 · 마이**다.
 */
@Composable
fun StoreScreen(
    onSearch: () -> Unit = {},
    onCart: () -> Unit = {},
    onMy: () -> Unit = {},
) {
    Column(Modifier.fillMaxSize()) {
        StoreHeader(onSearch = onSearch, onCart = onCart, onMy = onMy)
        // TODO: 보유 마일리지 · 카테고리 · 상품 그리드가 붙으면 교체한다 (SPEC S-01).
        PlaceholderScreen("S-01", "스토어", "마일리지로 굿즈·음료 교환")
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
