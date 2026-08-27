package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 스토어 검색 판 (DESIGN.md §6.9).
 *
 * **누르는 자리(스토어 헤더)와 치는 자리(검색 모드)가 같은 판이어야 바뀔 때 안 튄다.**
 * §6.9 가 그렇게 못 박아 뒀는데도 두 화면이 **각자 그리고 있었다** (2026-08-27 실측) —
 * 값이 우연히 같았을 뿐이라 한쪽만 고치면 그날로 어긋난다. 그래서 판을 여기 한 벌로 모은다.
 *
 * 판만 맡는다. 안에 무엇이 들어가는지는 쓰는 쪽이 정한다 —
 * 헤더는 `상품 검색` 글자, 검색 모드는 입력칸과 지우개다.
 *
 * ⚠️ 누름은 **판이 맡는다.** 물결이 판 밖으로 새지 않으려면 칠과 안쪽 여백 **사이**에
 * 들어가야 하는데, 그 자리를 쓰는 쪽에 맡기면 화면마다 순서가 달라진다
 */
@Composable
fun StoreSearchShell(
    modifier: Modifier = Modifier,
    /** 누르면 검색 모드로. 치는 자리(입력)일 때는 `null` — 이미 그 자리다 */
    onClick: (() -> Unit)? = null,
    content: @Composable RowScope.() -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .height(40.dp)
            // 누름 축소는 **아이콘에만** 준다 (§6.7). 판이 통째로 움찔거리면 화면이 흔들려 보인다
            .background(MyFisColor.Surface2, MyFisRadius.md)
            .then(
                if (onClick != null) Modifier.tapWithHaptics(interaction, onClick) else Modifier,
            )
            .padding(horizontal = MyFisSpacing.md),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_header_search),
            contentDescription = null, // 옆 문구·입력칸이 이름 역할을 한다
            tint = MyFisColor.TextTertiary,
            modifier = Modifier.size(20.dp),
        )
        content()
    }
}
