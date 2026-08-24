package com.myfis.app.ui.shell

import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Box
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
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * 밀려 들어온 화면(잎 화면)의 상단 바.
 *
 * 셸의 [AppHeader] 와 높이(56)·좌우 여백을 맞춰 두 화면이 겹칠 때 제목 줄이 흔들리지 않는다.
 * 워드마크 자리에는 화면 제목이 들어간다 — 헤더에 제목을 두지 않는다는 §6.9 규칙은
 * 탭 화면 이야기고, 잎 화면은 자기가 어디인지 밝혀야 한다.
 */
@Composable
fun DetailHeader(title: String, onBack: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(56.dp)
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        contentAlignment = Alignment.Center,
    ) {
        Text(title, style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)

        Box(
            modifier = Modifier
                .align(Alignment.CenterStart)
                // 터치 타겟 (DESIGN.md §5.3)
                .size(44.dp)
                .tapWithHaptics(interaction, onBack),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                painter = painterResource(R.drawable.ic_tab_back),
                contentDescription = "뒤로",
                tint = MyFisColor.TextPrimary,
                modifier = Modifier
                    .size(24.dp)
                    .graphicsLayer {
                        scaleX = press
                        scaleY = press
                    },
            )
        }
    }
}
