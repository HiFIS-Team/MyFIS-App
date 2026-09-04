package com.myfis.app.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * DESIGN.md §6.5 리스트 / 행.
 *
 * **규격만 있고 부를 수 있는 것이 없던 자리**다 (§10.1 에 적혀 있던 것) —
 * 마이(Y-01)가 이 행을 열 번 넘게 쓰면서 이제 만든다.
 *
 * - 높이 최소 `56`
 * - 값이 있으면 오른쪽에 붙는다 (`1,240 P` · `2장`)
 * - **꺾쇠는 실제로 이동하는 행에만** 단다 (§6.5)
 * - 좌우 여백은 **감싸는 카드가 준다** — 행이 또 주면 두 번 들어간다
 */
@Composable
fun MyFisListRow(
    title: String,
    /** 오른쪽에 붙는 **글자** 값 (`2장`) */
    value: String? = null,
    /** 눌러서 어딘가로 가는 행인가. 아니면 꺾쇠를 달지 않는다 */
    moves: Boolean = true,
    onClick: () -> Unit = {},
    modifier: Modifier = Modifier,
    /**
     * 글자로 못 쓰는 값 — **마일리지가 그렇다.** 포인트 표기는 `MileageText` 하나뿐이라(§3.3)
     * 여기에 그대로 넣는다. `value` 보다 우선한다
     */
    accessory: @Composable (() -> Unit)? = null,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = modifier
            .fillMaxWidth()
            .tapWithHaptics(interaction, onClick)
            .defaultMinSize(minHeight = MyFisSize.listRowMin),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        Text(
            title,
            style = MyFisTheme.type.body,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.weight(1f),
        )
        if (accessory != null) {
            accessory()
        } else if (value != null) {
            Text(value, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        }
        if (moves) {
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(18.dp).rotate(-90f),
            )
        }
    }
}

/** 카드 안에서 행과 행을 가르는 줄 (§6.5) — `border.subtle` 1 */
@Composable
fun MyFisRowDivider(modifier: Modifier = Modifier) {
    Box(modifier.fillMaxWidth().height(1.dp).background(MyFisColor.BorderSubtle))
}
