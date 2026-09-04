package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * SPEC.md G-03 모임 개설 **2단계 — 모임 소개** (DESIGN.md §6.32).
 *
 * 레퍼런스는 **당근 모임 만들기 2단계**. 1단계(§6.30)가 *무엇을* 묻는다면 여기는 *어떤 모임인지* 묻는다.
 *
 * **AI 도움받기가 이 화면의 주인공이다.** 소개 글은 쓰기 어려워서 대개 비어 있거나 한 줄로 끝난다 —
 * 우리 앱은 이미 AI 가 루틴을 짜고 식단을 읽으므로 여기서도 같은 손을 빌린다.
 *
 * **원본과 다른 것**
 * - 원본의 `Beta` 뱃지는 **주황·보라 그라디언트**다. 우리는 색이 하나고 그라디언트는 진행바만 쓴다
 *   → 판은 중립(`surface.3`)으로 두고 **AI 봇 그림**을 앞에 세웠다.
 *   그 그림은 이미 `AI 퀴즈`(§6.23)가 쓰는 얼굴이라 **앱 안에서 AI 는 늘 같은 얼굴**이 된다
 * - 원본 `TIP` 뱃지는 파랑이다. 색을 하나 더 만들지 않고 중립으로 뒀다 —
 *   이 화면의 라임은 **토글과 `모임 만들기` 둘**이 이미 쓰고 있다 (§3.2 상한)
 */
@Composable
fun GroupIntroScreen(
    onClose: () -> Unit = {},
    onBack: () -> Unit = {},
    onCreate: (String) -> Unit = {},
) {
    var intro by rememberSaveable { mutableStateOf("") }
    var useAI by rememberSaveable { mutableStateOf(false) }
    val ready = intro.trim().isNotEmpty()

    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        Row(
            Modifier.fillMaxWidth().height(MyFisSize.header)
                .padding(horizontal = MyFisSpacing.screenHorizontal),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            HeaderIcon(R.drawable.ic_header_close, "닫기", onClose)
        }

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            Text(
                "모임을 소개해주세요",
                style = MyFisTheme.type.titleLg,
                color = MyFisColor.TextPrimary,
                modifier = Modifier.padding(bottom = MyFisSpacing.xl),
            )

            AiToggleRow(useAI) { useAI = it }

            Spacer(Modifier.height(MyFisSpacing.xxl))

            if (useAI) {
                AiLoading()
            } else {
                IntroEditor(intro) { intro = it }
                Spacer(Modifier.height(MyFisSpacing.xl))
                TipBlock()
            }
        }

        // **`이전` 이 좁고 `모임 만들기` 가 넓다** — 나란히 두되 무게를 다르게 준다.
        // 같은 폭으로 두면 되돌아가는 길과 끝내는 길이 같은 값으로 읽힌다
        Row(
            Modifier
                .fillMaxWidth()
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.md),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            MyFisSecondaryButton(
                text = "이전",
                onClick = onBack,
                modifier = Modifier.width(104.dp),
                tall = true,
            )
            MyFisPrimaryButton(
                text = "모임 만들기",
                onClick = { onCreate(intro) },
                enabled = ready,
                modifier = Modifier.weight(1f),
            )
        }
    }
}

/** 켜고 끄는 줄은 **네이티브 스위치 그대로** 쓴다 — 직접 그리면 두 판이 어긋난다 */
@Composable
private fun AiToggleRow(checked: Boolean, onCheck: (Boolean) -> Unit) {
    MyFisCard {
        Row(
            Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
        ) {
            BetaBadge()
            Text("AI로 소개 도움받기", style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
            Spacer(Modifier.weight(1f))
            Switch(
                checked = checked,
                onCheckedChange = onCheck,
                colors = SwitchDefaults.colors(
                    checkedThumbColor = MyFisColor.OnAccent,
                    checkedTrackColor = MyFisColor.Accent,
                    checkedBorderColor = MyFisColor.Accent,
                    uncheckedThumbColor = MyFisColor.TextPrimary,
                    uncheckedTrackColor = MyFisColor.Surface3,
                    uncheckedBorderColor = MyFisColor.BorderSubtle,
                ),
            )
        }
    }
}

@Composable
private fun IntroEditor(value: String, onChange: (String) -> Unit) {
    Text("모임 소개", style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
    Spacer(Modifier.height(MyFisSpacing.sm))
    Box(
        Modifier
            .fillMaxWidth()
            .height(200.dp)
            .background(MyFisColor.Surface2, MyFisRadius.md)
            .padding(MyFisSpacing.md),
    ) {
        BasicTextField(
            value = value,
            onValueChange = { if (it.length <= IntroLimit) onChange(it) },
            textStyle = MyFisTheme.type.body.copy(color = MyFisColor.TextPrimary),
            cursorBrush = SolidColor(MyFisColor.Accent),
            modifier = Modifier.fillMaxSize(),
            decorationBox = { field ->
                if (value.isEmpty()) {
                    Text(
                        "어떤 활동을 하는지 적어 주세요. 소개가 잘 쓰인 모임에 사람이 모입니다.",
                        style = MyFisTheme.type.body,
                        color = MyFisColor.TextTertiary,
                    )
                }
                field()
            },
        )
    }
    // 남은 글자가 아니라 **쓴 글자**를 센다 — 한도는 벽이지 목표가 아니다
    Text(
        "${value.length}/$IntroLimit",
        style = MyFisTheme.type.caption,
        color = MyFisColor.TextTertiary,
        modifier = Modifier.fillMaxWidth().padding(top = MyFisSpacing.sm),
        textAlign = TextAlign.End,
    )
}

/** **빈 칸 앞에서 뭘 쓸지 모르는 게 진짜 문제다.** 그래서 질문으로 준다 */
@Composable
private fun TipBlock() {
    // **안내는 `info` 다** 🟢 (2026-09-04, 사용자 지정) — 라임이 아니라 파랑이라
    // §3.2 액센트 2곳(스위치·`모임 만들기`)을 안 건드린다. `도움 됐어요`(§6.14)와 같은 꼴 —
    // 글자와 16% 배경을 같은 색으로 둔다
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Text(
            "TIP",
            style = MyFisTheme.type.caption,
            color = MyFisColor.Info,
            modifier = Modifier
                .background(MyFisColor.Info.copy(alpha = 0.16f), MyFisRadius.full)
                .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
        )
        Text("이런 내용을 적으면 좋아요", style = MyFisTheme.type.bodySm, color = MyFisColor.Info)
    }
    Spacer(Modifier.height(MyFisSpacing.md))
    MyFisCard {
        introTips.forEach { line ->
            Row(
                Modifier.padding(bottom = MyFisSpacing.sm),
                horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                // 질문은 **읽으라고 있는 글**이다 (사용자 지정) — 흐리게 두면
                // 각주처럼 읽혀 빈 칸을 채우는 데 도움이 안 된다
                Text("・", style = MyFisTheme.type.bodySm, color = MyFisColor.TextTertiary)
                Text(line, style = MyFisTheme.type.bodySm, color = MyFisColor.TextPrimary)
            }
        }
    }
}

/** **스켈레톤이다** (§6.7 로딩) — 스피너를 쓰지 않는다. 레이아웃이 튀지 않는다 */
@Composable
private fun AiLoading() {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_benefit_quiz),
            contentDescription = null,
            tint = Color.Unspecified,
            modifier = Modifier.size(22.dp),
        )
        Text(
            "모임 소개에 필요한 질문을 만들고 있어요",
            style = MyFisTheme.type.titleSm,
            color = MyFisColor.TextPrimary,
        )
    }
    Spacer(Modifier.height(MyFisSpacing.md))
    SkeletonBar(1f)
    Spacer(Modifier.height(MyFisSpacing.md))
    SkeletonBar(0.55f)
}

/**
 * `Beta` 뱃지 — **AI 는 앱 안에서 늘 같은 얼굴이다** (`AI 퀴즈` §6.23 과 같은 그림).
 *
 * ⚠️ 봇 그림에 tint 를 걸지 않는다 — 파랑·남색·시안 세 색이 있어야 얼굴이 되고,
 * 한 색으로 누르면 실루엣만 남는다 (§8)
 */
@Composable
private fun BetaBadge() {
    Row(
        Modifier
            .background(MyFisColor.Surface3, MyFisRadius.full)
            .padding(horizontal = MyFisSpacing.sm, vertical = 3.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_benefit_quiz),
            contentDescription = null,
            tint = Color.Unspecified,
            modifier = Modifier.size(14.dp),
        )
        Text("Beta", style = MyFisTheme.type.caption, color = MyFisColor.TextSecondary)
    }
}

/** 로딩 자리막이 (§6.7) — 폭만 다르게 두 줄이면 "글이 올 자리"로 읽힌다 */
@Composable
private fun SkeletonBar(ratio: Float) {
    Box(
        Modifier
            .fillMaxWidth(ratio)
            .height(28.dp)
            .background(MyFisColor.Surface2, MyFisRadius.full),
    )
}

private const val IntroLimit = 500

private val introTips = listOf(
    "주로 어떤 활동을 하나요?",
    "언제, 어디에서 모이나요?",
    "어떤 분들과 함께하고 싶나요?",
    "지켜야 할 규칙이 있나요? (가입 조건 · 출석 · 나가는 기준)",
)
