package com.myfis.app.ui.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 섹션 제목 (DESIGN.md §4.2 — 섹션 제목은 `title.md`).
 *
 * 세 화면이 **같은 이름으로 각자** 그리고 있었다 (운동 상세 · 마이 · 혜택, 2026-09-08 실측).
 * 셋 다 `title.md` + `text.primary` 라 같은 것인데, 다른 건 **여백과 곁말**뿐이었다.
 *
 * **여백은 여기서 주지 않는다** — 화면마다 다르므로 `modifier` 로 받는다.
 * 섹션 사이 간격(`sectionGap`)도 부르는 쪽 몫이다.
 */
@Composable
fun MyFisSectionTitle(
    title: String,
    modifier: Modifier = Modifier,
    /** 오른쪽 곁말 — 마이의 지점 이름처럼 제목과 짝이 되는 값 */
    trailing: String? = null,
) {
    Row(
        modifier = modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(title, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        if (trailing != null) {
            Spacer(Modifier.weight(1f))
            Text(trailing, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        }
    }
}
