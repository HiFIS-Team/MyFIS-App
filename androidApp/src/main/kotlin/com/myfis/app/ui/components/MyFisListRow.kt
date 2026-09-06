package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 목록 한 줄 (DESIGN.md §6.5) — 높이 최소 `56`, 좌우는 화면 여백(`20`).
 *
 * 마이(Y-01)·설정(Y-03)·내 멤버십(M-06) 처럼 **글자 한 줄 + 값 + 꺾쇠**가
 * 줄줄이 서는 화면이 앞으로 여럿이라 공용으로 둔다.
 *
 * **꺾쇠는 값이 있는 줄에만 기본으로 붙는다** (레퍼런스 관행 · §6.5 "실제로 이동하는 행에만").
 * 값 없이 이동만 하는 줄은 `chevron = true` 로 켠다.
 */
@Composable
fun MyFisListRow(
    title: String,
    modifier: Modifier = Modifier,
    /** 오른쪽 값 — `앱 버전 0.1.0` 처럼 읽기만 하는 값도 여기 온다 */
    value: String? = null,
    titleColor: Color = MyFisColor.TextPrimary,
    titleStyle: TextStyle = MyFisTheme.type.body,
    chevron: Boolean = value != null,
    onClick: (() -> Unit)? = null,
    /** 값 대신 넣는 것 — 버튼·마일리지 표기처럼 글자 한 줄로 안 되는 자리 */
    trailing: (@Composable RowScope.() -> Unit)? = null,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .heightIn(min = MyFisSize.listRowMin)
            .then(
                if (onClick != null) Modifier.tapWithHaptics(interaction, onClick) else Modifier,
            )
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = titleStyle, color = titleColor)
        Spacer(Modifier.weight(1f))
        trailing?.invoke(this)
        if (value != null) {
            Text(
                value,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(start = MyFisSpacing.sm),
            )
        }
        if (chevron) Chevron(Modifier.padding(start = MyFisSpacing.xs))
    }
}

/** 구분선 (DESIGN.md §6.5) — **좌측 인덴트 없이 전체 너비**다 */
@Composable
fun MyFisDivider(modifier: Modifier = Modifier) {
    Box(
        modifier
            .fillMaxWidth()
            .height(1.dp)
            .background(MyFisColor.BorderSubtle),
    )
}
