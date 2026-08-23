package com.myfis.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.tooling.preview.Preview
import com.myfis.app.shared.Greeting
import com.myfis.app.ui.shell.AppShell
import com.myfis.app.ui.theme.ColorSwatch
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisDangerButton
import com.myfis.app.ui.theme.MyFisGhostButton
import com.myfis.app.ui.theme.MyFisMetricCard
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisProgress
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 다크 고정이므로 시스템 바도 항상 어둡게 (DESIGN.md §9 이탈 #1)
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(android.graphics.Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        setContent {
            MyFisTheme {
                AppShell()
            }
        }
    }
}

/** DESIGN.md 토큰이 실제로 어떻게 보이는지 확인하는 화면. 구현이 시작되면 교체된다. */
@Composable
fun DesignTokensScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = MyFisSpacing.screenHorizontal)
            .padding(top = 64.dp, bottom = 48.dp),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sectionGap),
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
            Text("MyFIS", style = MyFisTheme.type.titleLg)
            Text(
                "디자인 토큰 · ${Greeting().greet()}",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
            )
        }

        Section("숫자 카드 (§6.3)") {
            MyFisMetricCard(
                label = "남은 기간",
                value = "42",
                unit = "일",
                caption = "2027. 2. 23. 만료",
                progress = 0.62f,
            )
            MyFisMetricCard(
                label = "남은 기간",
                value = "5",
                unit = "일",
                caption = "만료 7일 이내 — warning",
                progress = 0.08f,
                valueColor = MyFisColor.Warning,
            )
        }

        Section("타이포 스케일 (§4.2)") {
            MyFisCard {
                Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
                    Text("4,250", style = MyFisTheme.type.metricXl, color = MyFisColor.Accent)
                    Text("metric.xl 56", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
                    Text("1,240", style = MyFisTheme.type.metricLg)
                    Text("metric.lg 40", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
                    Text("8 / 20", style = MyFisTheme.type.metricMd)
                    Text("metric.md 28", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
                    Text("화면 제목 title.lg", style = MyFisTheme.type.titleLg)
                    Text("섹션 제목 title.md", style = MyFisTheme.type.titleMd)
                    Text("카드 제목 title.sm", style = MyFisTheme.type.titleSm)
                    Text("본문입니다 body 16", style = MyFisTheme.type.body)
                    Text("보조 본문 body.sm 14", style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
                    Text("라벨 label 13", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
                    Text("캡션 caption 12", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
                }
            }
        }

        Section("버튼 (§6.1)") {
            Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
                MyFisPrimaryButton("운동 시작", onClick = {})
                MyFisPrimaryButton("비활성 — alpha 안 씀", onClick = {}, enabled = false)
                MyFisSecondaryButton("보조 액션", onClick = {})
                MyFisGhostButton("건너뛰기", onClick = {})
                MyFisDangerButton("예약 취소", onClick = {})
            }
        }

        Section("진행률 (§6.4)") {
            MyFisCard {
                Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.lg)) {
                    Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
                        Text("0%", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
                    }
                    MyFisProgress(0f)
                    MyFisProgress(0.35f)
                    MyFisProgress(1f)
                }
            }
        }

        Section("컬러 토큰 (§3.1)") {
            MyFisCard {
                Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
                    ColorSwatch("accent", MyFisColor.Accent, "#C9F531")
                    ColorSwatch("surface.1", MyFisColor.Surface1, "#0E0F12")
                    ColorSwatch("surface.2", MyFisColor.Surface2, "#16181D")
                    ColorSwatch("surface.3", MyFisColor.Surface3, "#1F2229")
                    ColorSwatch("text.primary", MyFisColor.TextPrimary, "#FFFFFF")
                    ColorSwatch("text.secondary", MyFisColor.TextSecondary, "#A3A9B5")
                    ColorSwatch("text.tertiary", MyFisColor.TextTertiary, "#828997")
                    ColorSwatch("border.strong", MyFisColor.BorderStrong, "#6B7383")
                    ColorSwatch("success", MyFisColor.Success, "#4ADE80")
                    ColorSwatch("warning", MyFisColor.Warning, "#FBBF24")
                    ColorSwatch("danger", MyFisColor.Danger, "#FF6B6B")
                    ColorSwatch("info", MyFisColor.Info, "#7DA8FF")
                }
            }
        }
    }
}

@Composable
private fun Section(title: String, content: @Composable () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.md)) {
        Text(title, style = MyFisTheme.type.titleMd)
        content()
    }
}

@Preview(showBackground = true, backgroundColor = 0xFF000000, heightDp = 1400)
@Composable
private fun DesignTokensPreview() {
    MyFisTheme { DesignTokensScreen() }
}
