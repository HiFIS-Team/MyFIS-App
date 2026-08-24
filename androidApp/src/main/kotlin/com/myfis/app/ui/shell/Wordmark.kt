package com.myfis.app.ui.shell

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.withStyle
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 워드마크 — `My` 는 흰색, `FIS` 는 액센트.
 *
 * 서체는 Quicksand Bold. 본문 서체(Pretendard)와 다른 유일한 자리다.
 * 액센트를 쓰는 곳이므로 **같은 화면에서 액센트 사용 예산 1칸을 차지한다** (DESIGN.md §2 원칙 3).
 */
@Composable
fun Wordmark(modifier: Modifier = Modifier) {
    Text(
        text = wordmarkText(),
        style = MyFisTheme.type.wordmark,
        modifier = modifier,
    )
}

@Composable
private fun wordmarkText(): AnnotatedString = buildAnnotatedString {
    withStyle(SpanStyle(color = MyFisColor.TextPrimary)) { append("My") }
    withStyle(SpanStyle(color = MyFisColor.Accent)) { append("FIS") }
}
