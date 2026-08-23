package com.myfis.app.ui.theme

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp

/** DESIGN.md §6.1 Primary — 화면당 1개 */
@Composable
fun MyFisPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier.fillMaxWidth().height(MyFisSize.buttonPrimary),
        shape = MyFisRadius.full,
        colors = ButtonDefaults.buttonColors(
            containerColor = MyFisColor.Accent,
            contentColor = MyFisColor.OnAccent,
            // 비활성에 alpha 를 쓰지 않는다 (§9 의도된 이탈 #2) — 색 토큰 자체를 바꾼다.
            disabledContainerColor = MyFisColor.Surface2,
            disabledContentColor = MyFisColor.TextTertiary,
        ),
    ) {
        Text(text = text, style = MyFisTheme.type.titleSm)
    }
}

/** DESIGN.md §6.1 Secondary */
@Composable
fun MyFisSecondaryButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Button(
        onClick = onClick,
        modifier = modifier.fillMaxWidth().height(MyFisSize.buttonSecondary),
        shape = MyFisRadius.full,
        colors = ButtonDefaults.buttonColors(
            containerColor = MyFisColor.Surface2,
            contentColor = MyFisColor.TextPrimary,
        ),
    ) {
        Text(text = text, style = MyFisTheme.type.bodySm)
    }
}

/** DESIGN.md §6.1 Ghost */
@Composable
fun MyFisGhostButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    TextButton(
        onClick = onClick,
        modifier = modifier.fillMaxWidth().height(MyFisSize.buttonSecondary),
        colors = ButtonDefaults.textButtonColors(contentColor = MyFisColor.TextSecondary),
    ) {
        Text(text = text, style = MyFisTheme.type.bodySm)
    }
}

/** DESIGN.md §6.1 Danger */
@Composable
fun MyFisDangerButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.fillMaxWidth().height(MyFisSize.buttonSecondary),
        shape = MyFisRadius.full,
        colors = ButtonDefaults.outlinedButtonColors(contentColor = MyFisColor.Danger),
    ) {
        Text(text = text, style = MyFisTheme.type.bodySm)
    }
}

/** DESIGN.md §6.2 카드 */
@Composable
fun MyFisCard(
    modifier: Modifier = Modifier,
    content: @Composable ColumnScopeAlias.() -> Unit,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(MyFisColor.Surface1, MyFisRadius.md)
            .padding(MyFisSpacing.cardPadding),
        content = content,
    )
}

typealias ColumnScopeAlias = androidx.compose.foundation.layout.ColumnScope

/** DESIGN.md §6.4 진행률 — 트랙은 0%일 때도 보여준다 */
@Composable
fun MyFisProgress(progress: Float, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(MyFisSize.progressHeight)
            .background(MyFisColor.Surface3, MyFisRadius.full),
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(progress.coerceIn(0f, 1f))
                .height(MyFisSize.progressHeight)
                .background(MyFisColor.Accent, MyFisRadius.full),
        )
    }
}

/**
 * DESIGN.md §6.3 숫자 카드 — 이 앱의 시그니처.
 * 라벨이 숫자 '위'에 온다 (읽는 순서: 뭘 보는지 → 값).
 */
@Composable
fun MyFisMetricCard(
    label: String,
    value: String,
    unit: String,
    caption: String,
    progress: Float,
    valueColor: Color = MyFisColor.Accent,
    modifier: Modifier = Modifier,
) {
    MyFisCard(modifier) {
        Text(label, style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
        Row(
            modifier = Modifier.padding(top = MyFisSpacing.sm),
            verticalAlignment = Alignment.Bottom,
        ) {
            Text(value, style = MyFisTheme.type.metricXl, color = valueColor)
            Text(
                unit,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextSecondary,
                modifier = Modifier.padding(start = MyFisSpacing.sm, bottom = 10.dp),
            )
        }
        MyFisProgress(progress, Modifier.padding(top = MyFisSpacing.md))
        Text(
            caption,
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextTertiary,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
    }
}

/** 토큰 확인용 컬러 스와치 */
@Composable
internal fun ColorSwatch(name: String, color: Color, hex: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        Box(
            Modifier
                .height(36.dp)
                .fillMaxWidth(0.18f)
                .background(color, RoundedCornerShape(8.dp)),
        )
        Text(name, style = MyFisTheme.type.bodySm, modifier = Modifier.fillMaxWidth(0.55f))
        Text(
            hex,
            style = MyFisTheme.type.caption,
            color = MyFisColor.TextTertiary,
            textAlign = TextAlign.End,
            modifier = Modifier.fillMaxWidth(),
        )
    }
}
