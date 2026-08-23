package com.myfis.app.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf

val LocalMyFisTypography = staticCompositionLocalOf { myFisTypography }

/**
 * DESIGN.md §10 코드 매핑.
 *
 * - 라이트 모드를 지원하지 않는다 (§9 의도된 이탈 #1). [isSystemInDarkTheme] 을 보지 않는다.
 * - Material You 다이나믹 컬러는 쓰지 않는다. 기기마다 브랜드 색이 달라지면 §2 원칙 3이 무너진다.
 * - 반드시 [Surface] 로 감싼다. 안 그러면 LocalContentColor 가 검정이라 색을 지정하지 않은 Text 가 사라진다.
 */
@Composable
fun MyFisTheme(content: @Composable () -> Unit) {
    val colorScheme = darkColorScheme(
        primary = MyFisColor.Accent,
        onPrimary = MyFisColor.OnAccent,
        secondary = MyFisColor.Surface2,
        onSecondary = MyFisColor.TextPrimary,
        background = MyFisColor.BgBase,
        onBackground = MyFisColor.TextPrimary,
        surface = MyFisColor.Surface1,
        onSurface = MyFisColor.TextPrimary,
        surfaceVariant = MyFisColor.Surface2,
        onSurfaceVariant = MyFisColor.TextSecondary,
        outline = MyFisColor.BorderStrong,
        outlineVariant = MyFisColor.BorderSubtle,
        error = MyFisColor.Danger,
        onError = MyFisColor.OnAccent,
    )

    CompositionLocalProvider(LocalMyFisTypography provides myFisTypography) {
        MaterialTheme(colorScheme = colorScheme) {
            Surface(
                color = MyFisColor.BgBase,
                contentColor = MyFisColor.TextPrimary,
                content = content,
            )
        }
    }
}

/** `MyFisTheme.type.metricXl` 처럼 쓴다. */
object MyFisTheme {
    val type: MyFisTypography
        @Composable get() = LocalMyFisTypography.current
}
