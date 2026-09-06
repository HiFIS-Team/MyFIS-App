package com.myfis.app.ui.components

import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor

/**
 * 꺾쇠 — **아래 꺾쇠 아이콘 한 벌을 돌려 쓴다** (DESIGN.md §6.14 · §8).
 *
 * iOS `Components/Chevron.swift` 와 같은 것이다. 화면마다 같은 걸
 * `private fun Chevron` 으로 따로 그리고 있어서 (유산소 · 스토어 마이) 한 벌로 올린다.
 */
@Composable
fun Chevron(
    modifier: Modifier = Modifier,
    /** 도는 각도 — `-90` 오른쪽(이동) · `0` 아래(펼침) · `180` 위(접힘) */
    degrees: Float = -90f,
    size: Dp = 20.dp,
    color: Color = MyFisColor.TextTertiary,
) {
    Icon(
        painter = painterResource(R.drawable.ic_chevron_down),
        contentDescription = null,
        tint = color,
        modifier = modifier
            .size(size)
            .graphicsLayer { rotationZ = degrees },
    )
}
