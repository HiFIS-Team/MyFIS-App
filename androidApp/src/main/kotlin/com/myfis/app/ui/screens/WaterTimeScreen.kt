package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * P-05 물 마시기 — **미션 시각 고르기** (SPEC P-05).
 *
 * 레퍼런스는 토스 `언제 마실까요?` 다 (사용자 지정). 짜임만 가져온다.
 *
 * ⚠️ **고른 칩을 라임으로 칠하지 않는다.** 원본은 고른 칩 셋 + 오른쪽 요약 셋 + 버튼까지
 * 전부 민트라 강조가 일곱 곳이다. 우리는 화면당 **두 곳**이 상한이고(§2 원칙 3),
 * 주간 캘린더(§6.11)가 이미 답을 냈다 — **선택은 표면 밝기와 글자 밝기로.**
 * 이 화면의 라임은 **하단 `설정하기` 하나뿐**이다.
 */
@Composable
fun WaterTimeScreen(
    /** 지금 걸린 미션 시각 */
    times: Map<String, String> = waterDefaultTimes,
    /** `설정하기` 를 누르면 고른 시각을 넘긴다 */
    onSave: (Map<String, String>) -> Unit = {},
    onBack: () -> Unit = {},
) {
    // 고를 때만 여기서 들고 있고, **저장을 눌러야** 밖으로 나간다 —
    // 되돌아가면 고르던 것은 버려진다
    val picked = remember(times) { mutableStateMapOf<String, String>().apply { putAll(times) } }

    Column(
        Modifier
            .fillMaxSize()
            // **흰 바탕** — 혜택의 활동 화면은 밝다 (§9 이탈 #1, 2026-08-28 개정)
            .background(MyFisColor.LightBgBase)
            .statusBarsPadding()
            .navigationBarsPadding(),
    ) {
        DetailHeader(title = "물 마시기", onBack = onBack, light = true)

        Column(
            Modifier
                .weight(1f)
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
            Column(Modifier.padding(horizontal = MyFisSpacing.screenHorizontal)) {
                Text(
                    "언제 마실까요?",
                    style = MyFisTheme.type.titleLg,
                    color = MyFisColor.LightTextPrimary,
                )
                Text(
                    "고른 시간에 알려드려요",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.LightTextSecondary,
                    modifier = Modifier.padding(top = MyFisSpacing.sm),
                )
            }

            waterSlots.forEachIndexed { index, slot ->
                SlotCard(
                    slot = slot,
                    picked = picked[slot.name] ?: slot.times.first(),
                    onPick = { picked[slot.name] = it },
                    modifier = Modifier
                        .padding(horizontal = MyFisSpacing.screenHorizontal)
                        .padding(top = if (index == 0) MyFisSpacing.sectionGap else MyFisSpacing.cardGap),
                )
            }
        }

        Column(
            Modifier
                .background(MyFisColor.LightBgBase)
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(vertical = MyFisSpacing.md),
        ) {
            MyFisPrimaryButton(
            "설정하기",
            onClick = { onSave(picked.toMap()); onBack() },
            light = true,
            // 활동 화면의 Primary 는 **그 활동의 색**이다 (2026-08-28)
            fill = MyFisColor.LightAccentCyan,
            onFill = MyFisColor.LightBgBase,
        )
        }
    }
}

/** 때 한 장 — 머리(그림 · 이름 ↔ 고른 값) + 시각 칩들 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun SlotCard(
    slot: WaterSlot,
    picked: String,
    onPick: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    MyFisCard(modifier, light = true) {
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(slot.emoji, style = MyFisTheme.type.titleMd)
            Text(
                slot.name,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.LightTextPrimary,
                modifier = Modifier
                    .weight(1f)
                    .padding(start = MyFisSpacing.sm),
            )
            // 고른 값을 다시 적는다 — 칩이 여러 줄이면 무엇을 골랐는지 한눈에 안 잡힌다.
            // **라임을 쓰지 않는다** (원본은 민트다) — 흰 글자로 충분히 앞선다
            Text(
                picked.asClock(),
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.LightTextPrimary,
            )
        }

        FlowRow(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = MyFisSpacing.lg),
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        ) {
            slot.times.forEach { time ->
                TimeChip(time = time, selected = time == picked, onPick = { onPick(time) })
            }
        }
    }
}

/**
 * 시각 칩. **고른 것은 판을 한 단계 올리고 테두리를 두른다** (§5.4 위계는 표면 밝기).
 *
 * ⚠️ 높이는 `size.chip`(36) 이 아니라 **터치 타겟(48)** 이다 — 마일리지 칩과 달리
 * 이건 **누르는 칩**이라 §5.3 최소치를 지켜야 한다
 */
@Composable
private fun TimeChip(time: String, selected: Boolean, onPick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Box(
        modifier = Modifier
            .height(MyFisSize.minTouchTarget)
            .background(
                if (selected) MyFisColor.LightSurface3 else MyFisColor.LightSurface2,
                MyFisRadius.md,
            )
            // 고른 칩은 **라임 테두리**. 흰 면에서 라임은 밝기 대비가 낮지만 채도가 높아
            // **색으로 읽힌다** — 테두리는 강조만 하고 뜻은 글자가 진다 (2026-08-28 확인)
            .border(
                width = if (selected) 1.5.dp else 1.dp,
                color = if (selected) MyFisColor.LightAccentCyan else Color.Transparent,
                shape = MyFisRadius.md,
            )
            .tapWithHaptics(interaction, onPick)
            .padding(horizontal = MyFisSpacing.lg),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            time,
            style = if (selected) {
                MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum")
            } else {
                MyFisTheme.type.body.copy(fontFeatureSettings = "tnum")
            },
            color = if (selected) MyFisColor.LightTextPrimary else MyFisColor.LightTextSecondary,
        )
    }
}

/** `8:00` → `오전 8시` — 머리에서는 문장으로 읽히는 편이 낫다 */
private fun String.asClock(): String {
    val hour = substringBefore(":").toIntOrNull() ?: return this
    val minute = substringAfter(":")
    val half = if (minute == "30") " 30분" else ""
    return when {
        hour < 12 -> "오전 ${hour}시$half"
        hour == 12 -> "오후 12시$half"
        else -> "오후 ${hour - 12}시$half"
    }
}

data class WaterSlot(val emoji: String, val name: String, val times: List<String>)

/** 처음 걸려 있는 미션 시각. TODO(서버): 회원이 고른 값을 서버가 준다 (SPEC P-05) */
val waterDefaultTimes = mapOf("아침" to "8:00", "점심" to "12:00", "저녁" to "18:00")

// TODO(서버): 미션 시각 후보를 서버가 준다 (SPEC P-05)
val waterSlots = listOf(
    WaterSlot("⛅", "아침", listOf("7:00", "7:30", "8:00", "8:30", "9:00")),
    WaterSlot("🌞", "점심", listOf("11:00", "11:30", "12:00", "12:30", "13:00")),
    WaterSlot("🌙", "저녁", listOf("17:00", "17:30", "18:00", "18:30", "19:00")),
)
