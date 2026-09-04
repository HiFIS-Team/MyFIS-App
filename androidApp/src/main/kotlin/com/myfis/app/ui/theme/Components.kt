package com.myfis.app.ui.theme

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.size
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
import androidx.compose.foundation.layout.PaddingValues
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
    /** 흰 바탕 화면(혜택·활동, §9 이탈 #1)에서는 **비활성** 면을 밝은 쪽으로 바꾼다 */
    light: Boolean = false,
    /** 활동 화면은 **그 활동의 갈래 색**으로 칠한다 (2026-08-28). 기본은 라임 */
    fill: Color = MyFisColor.Accent,
    onFill: Color = MyFisColor.OnAccent,
    /**
     * **떠 있는 알약**으로 그린다 (§6.28 유산소 탭, 2026-09-03).
     *
     * 탭 화면은 아래에 **떠 있는 탭 바**가 있어서, 폭을 다 쓰는 판을 얹으면
     * **둥근 덩어리가 둘로 겹쳐** 보이고 뒤 카드가 모서리에 반쯤 잘린다.
     * 탭 바와 **같은 `radius.full`** 로 맞추고 폭은 글자에 맡긴다.
     */
    pill: Boolean = false,
) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = modifier
            .then(if (pill) Modifier else Modifier.fillMaxWidth())
            .height(if (pill) MyFisSize.buttonSecondary else MyFisSize.buttonPrimary),
        shape = if (pill) MyFisRadius.full else MyFisRadius.md,
        contentPadding = if (pill) {
            PaddingValues(horizontal = MyFisSpacing.xxl)
        } else {
            ButtonDefaults.ContentPadding
        },
        colors = ButtonDefaults.buttonColors(
            containerColor = fill,
            contentColor = onFill,
            // 비활성에 alpha 를 쓰지 않는다 (§9 의도된 이탈 #2) — 색 토큰 자체를 바꾼다.
            disabledContainerColor = if (light) MyFisColor.LightSurface2 else MyFisColor.Surface2,
            disabledContentColor = if (light) MyFisColor.LightTextTertiary else MyFisColor.TextTertiary,
        ),
    ) {
        Text(text = text, style = MyFisTheme.type.titleSm)
    }
}

/** DESIGN.md §6.1 Secondary */
@Composable
fun MyFisSecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    /**
     * **Primary 와 나란히 설 때 켠다** 🟢 (2026-09-04) — 높이를 `buttonPrimary`(52) 로,
     * **글꼴도 `title.sm` 로** Primary 와 같이 맞춘다.
     *
     * 44/52 든 `body.sm`/`title.sm` 이든, 한 줄에 선 두 버튼이 어느 하나라도 다르면
     * **둘이 다른 종류의 버튼처럼** 보인다 (§6.32 모임 소개에서 두 번 다 드러났다)
     */
    tall: Boolean = false,
) {
    Button(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .height(if (tall) MyFisSize.buttonPrimary else MyFisSize.buttonSecondary),
        shape = MyFisRadius.md,
        colors = ButtonDefaults.buttonColors(
            containerColor = MyFisColor.Surface2,
            contentColor = MyFisColor.TextPrimary,
        ),
    ) {
        Text(text = text, style = if (tall) MyFisTheme.type.titleSm else MyFisTheme.type.bodySm)
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

/**
 * DESIGN.md §6.1 Small — **카드 안**에서 쓰는 보조 버튼.
 *
 * 전체 폭을 먹지 않는다. 카드 머리 줄처럼 다른 글자와 나란히 서는 자리용이다.
 */
@Composable
fun MyFisSmallButton(text: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    Button(
        onClick = onClick,
        modifier = modifier.height(MyFisSize.buttonSmall),
        shape = MyFisRadius.md,
        contentPadding = PaddingValues(horizontal = MyFisSpacing.lg),
        colors = ButtonDefaults.buttonColors(
            containerColor = MyFisColor.Surface2,
            contentColor = MyFisColor.TextPrimary,
        ),
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
        shape = MyFisRadius.md,
        colors = ButtonDefaults.outlinedButtonColors(contentColor = MyFisColor.Danger),
    ) {
        Text(text = text, style = MyFisTheme.type.bodySm)
    }
}

/**
 * DESIGN.md §6.2 카드
 *
 * 기본은 `radius.md`. **화면 폭을 다 쓰는 배너만 `radius.lg`** 다 (§6.2) —
 * 스토어 캐러셀·혜택 초대 배너가 둘 다 `lg` 로 그려져 있어 그 관행을 그대로 받는다.
 */
@Composable
fun MyFisCard(
    modifier: Modifier = Modifier,
    shape: androidx.compose.ui.graphics.Shape = MyFisRadius.md,
    /** 흰 바탕 화면(혜택·활동, §9 이탈 #1)에서는 면을 밝은 쪽으로 바꾼다 */
    light: Boolean = false,
    content: @Composable ColumnScopeAlias.() -> Unit,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(if (light) MyFisColor.LightSurface1 else MyFisColor.Surface1, shape)
            .padding(MyFisSpacing.cardPadding),
        content = content,
    )
}

/**
 * DESIGN.md §6.23 · §6.26 **아이콘 타일** — `56` 판 + `radius.tile` + `border.subtle` 1.
 *
 * 혜택 행 · 기구 찾기 빠른 고르기 · 자주 쓰는 기구가 **같은 판을 세 곳에서 따로 그리고 있었다**
 * (2026-08-27 실측). 판을 여기 한 벌로 모은다.
 *
 * - 테두리 한 줄이 판을 **타일**로 만든다 — 없으면 배경에 녹는다
 * - **크기를 받는다** 🟢 (2026-09-04) — 모임 레일(§6.29)이 `72` 판을 쓰면서
 *   `23.dp` 를 직접 박고 있었다. `radius.tile` 은 `56` 판에 맞춘 값이라(§5.2) 다른 크기에 그대로 못 쓴다 →
 *   **라운딩을 비율(`MyFisRadius.tileRatio`)로 뽑는다.** `56` 은 예전과 같은 `18` 이 나온다
 */
@Composable
fun MyFisIconTile(
    modifier: Modifier = Modifier,
    /** 이미 받은 줄처럼 한 단계 물러난 자리 — 판을 `surface.1` 로 내린다 */
    dimmed: Boolean = false,
    /** 판 한 변. 기본은 목록 행(`56`) */
    size: androidx.compose.ui.unit.Dp = MyFisSize.listRowMin,
    content: @Composable androidx.compose.foundation.layout.BoxScope.() -> Unit,
) {
    val shape = androidx.compose.foundation.shape.RoundedCornerShape(size * MyFisRadius.tileRatio)
    Box(
        modifier = modifier
            .size(size)
            .background(if (dimmed) MyFisColor.Surface1 else MyFisColor.Surface2, shape)
            .border(1.dp, MyFisColor.BorderSubtle, shape),
        contentAlignment = androidx.compose.ui.Alignment.Center,
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
