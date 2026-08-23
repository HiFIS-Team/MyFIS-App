package com.myfis.app.ui.shell

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/** 구현 전 자리. 화면이 붙으면 지운다. */
@Composable
fun PlaceholderScreen(id: String, title: String, description: String) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Text(id, style = MyFisTheme.type.label, color = MyFisColor.Accent)
        Text(
            title,
            style = MyFisTheme.type.titleLg,
            color = MyFisColor.TextPrimary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        Text(
            description,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextTertiary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(top = MyFisSpacing.xs),
        )
    }
}
