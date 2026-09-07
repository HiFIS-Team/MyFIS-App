package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 추천 상품 한 장 — 정사각 그림 자리 + 이름 + 마일리지.
 *
 * 상품 상세(§6.21 `함께 보면 좋아요`)와 내 교환(§6.20 `바꿀 만한 것`)이
 * **같은 것을 각자 그리고 있었다** (2026-09-08 실측). 둘이 어긋나 있던 것도 있다 —
 * 자리값 아이콘이 한쪽은 `40`, 다른 쪽은 `44` 였다. 합치면서 `44` 로 맞췄다.
 *
 * **크기는 부르는 쪽이 정한다** — 가로 캐러셀은 폭을 못 박고(`108`), 격자는 `weight` 로 나눈다.
 *
 * ⚠️ 모델(`StoreItem`)을 받지 않고 **값만 받는다.** 공용 조각이 화면 패키지를 알면
 * 의존 방향이 거꾸로 선다.
 */
@Composable
fun StoreSuggestionCard(
    name: String,
    price: Int,
    modifier: Modifier = Modifier,
    onClick: () -> Unit = {},
) {
    val interaction = remember { MutableInteractionSource() }

    Column(modifier = modifier.tapWithHaptics(interaction, onClick)) {
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
            name,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        MileageText(
            price,
            style = MyFisTheme.type.titleSm,
            modifier = Modifier.padding(top = 2.dp),
        )
    }
}
