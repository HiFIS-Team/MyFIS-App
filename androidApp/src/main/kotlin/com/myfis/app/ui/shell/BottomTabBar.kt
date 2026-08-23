package com.myfis.app.ui.shell

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * DESIGN.md §6.7 하단 탭.
 *
 * - 배경 surface.1, 상단 border.subtle 1px
 * - 활성 accent / 비활성 text.tertiary
 * - **Android 는 아이콘 + 라벨.** Material 관행이고, iOS 유리 바(아이콘만)와 다른 게 맞다 (§6.7)
 * - `이전` 탭은 성격이 다르므로 활성 색을 쓰지 않고 text.secondary 로 둔다
 */
@Composable
fun <T : Tab> BottomTabBar(
    tabs: List<T>,
    selected: T?,
    onSelect: (T) -> Unit,
    modifier: Modifier = Modifier,
    isExit: (T) -> Boolean = { false },
) {
    Column(modifier = modifier.fillMaxWidth().background(MyFisColor.Surface1)) {
        Box(Modifier.fillMaxWidth().height(1.dp).background(MyFisColor.BorderSubtle))
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .navigationBarsPadding()
                .padding(top = MyFisSpacing.sm, bottom = MyFisSpacing.xs),
            horizontalArrangement = Arrangement.SpaceEvenly,
        ) {
            tabs.forEach { tab ->
                TabItem(
                    tab = tab,
                    isSelected = tab == selected,
                    isExit = isExit(tab),
                    onClick = { onSelect(tab) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

@Composable
private fun TabItem(
    tab: Tab,
    isSelected: Boolean,
    isExit: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val tint: Color = when {
        isExit -> MyFisColor.TextSecondary
        isSelected -> MyFisColor.Accent
        else -> MyFisColor.TextTertiary
    }
    Column(
        modifier = modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick,
            )
            // 터치 타겟 48dp 확보 (DESIGN.md §5.3)
            .height(56.dp)
            .padding(vertical = MyFisSpacing.xs),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Icon(
            painter = painterResource(tab.icon),
            contentDescription = null, // 라벨이 바로 아래 있으므로 중복 읽지 않는다
            tint = tint,
            modifier = Modifier.size(24.dp),
        )
        Text(
            text = tab.label,
            style = MyFisTheme.type.caption,
            color = tint,
            modifier = Modifier.padding(top = 3.dp),
        )
    }
}
