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
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.shell.HeaderIcon
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

/**
 * SPEC.md G-03 모임 개설 (DESIGN.md §6.30).
 *
 * 레퍼런스는 **당근 모임 만들기 1단계**다 — `✕` · 큰 질문 · 이름 칸 · 갈래 칩(`더보기`) ·
 * 둘째 칸 · 바닥에 붙은 `다음`.
 *
 * **이 화면은 묻는 화면이다.** 그래서 §2 원칙 1 과 달리 **질문이 제일 크다** —
 * 계기판이 아니라 대화다 (G-01 과 같은 예외, §6.29).
 *
 * **원본에서 가져온 좋은 동작 둘**
 * - 이름을 치기 시작하면 **질문과 부제가 사라진다.** 화면이 *묻는 중* 에서 *채우는 중* 으로 바뀐다
 * - 갈래를 고르면 **그 칩이 맨 앞으로 온다.** 접었을 때도 고른 것이 늘 보인다
 *
 * **원본과 다른 것**
 * - 원본의 `활동 지역 · 활동 범위 · 지도` 가 통째로 빠졌다 — **우리 모임은 지점에 매여 있다.**
 *   그 자리에 **`모이는 때`** 를 넣었다 — 들어갈지 말지를 가르는 건 요일·시간이다 (§6.29)
 * - `다음` 은 흰색이 아니라 **라임**이다. 원본이 흰색인 건 당근 브랜드색이 주황이라
 *   큰 면적에 못 쓰기 때문이고, 우리는 그 제약이 없다
 */
@Composable
fun GroupCreateScreen(
    onClose: () -> Unit = {},
    /** TODO: 2단계(소개·정원)가 붙으면 연결한다 */
    onNext: (String, GroupCategory, String?) -> Unit = { _, _, _ -> },
) {
    var name by rememberSaveable { mutableStateOf("") }
    var category by rememberSaveable { mutableStateOf<GroupCategory?>(null) }
    var region by rememberSaveable { mutableStateOf<String?>(null) }
    var expanded by rememberSaveable { mutableStateOf(false) }

    /** 이름과 갈래가 있어야 다음이 뜻이 있다 */
    val ready = name.trim().isNotEmpty() && category != null

    // 잎 화면은 셸을 덮으므로 **상태바 여백을 스스로 챙긴다** (§7.1)
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        // `✕` 하나뿐이다 — 잎 화면이라 뒤가 아니라 **닫는다** (§6.9)
        Row(
            Modifier
                .fillMaxWidth()
                .height(MyFisSize.header)
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
            // **질문은 안 사라진다** 🟢 (2026-09-04, 사용자 지정).
            // 원본은 치기 시작하면 접는데, 그러면 **스크롤해서 돌아왔을 때
            // 여기가 무슨 화면인지 다시 알려 줄 게 없다**
            Text(
                "어떤 모임을 만들까요?",
                style = MyFisTheme.type.titleLg,
                color = MyFisColor.TextPrimary,
            )
            Text(
                "모임명과 갈래는 만든 뒤에도 바꿀 수 있어요",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                modifier = Modifier.padding(top = MyFisSpacing.sm, bottom = MyFisSpacing.xxl),
            )

            FieldLabel("모임명")
            NameField(name) { name = it }
            CategoryChips(
                selected = category,
                expanded = expanded,
                onSelect = { category = if (category == it) null else it },
                onToggle = { expanded = !expanded },
                modifier = Modifier.padding(top = MyFisSpacing.md),
            )

            // **활동 지역** 🟢 (2026-09-04, 사용자 지정).
            //
            // 처음엔 `모이는 때`(요일·시간) 를 뒀었다 — 모임이 지점에 매여 있으니
            // 지역을 물을 게 없다고 봤는데, **그 전제가 틀렸다.**
            // 이 탭의 취지가 *회원이 헬스장에만 묶이지 않는 것* 이라
            // **밖에서 모이는 자리**가 오히려 본령이다. 그래서 원본처럼 지역을 묻는다.
            //
            // 이름·갈래를 안 채워도 처음부터 보인다 — 원본도 그렇다
            Spacer(Modifier.height(MyFisSpacing.xxl))
            FieldLabel("활동 지역")
            RegionChips(region) { region = if (region == it) null else it }
        }

        // **바닥에 붙는다.** 다 채우고 누르는 버튼이라 떠 있을 이유가 없다 —
        // 이 화면은 탭 바가 없는 잎이라 §6.28 알약 규칙이 걸리지 않는다
        MyFisPrimaryButton(
            text = "다음",
            onClick = { onNext(name.trim(), category ?: GroupCategory.WEIGHT, region) },
            enabled = ready,
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(bottom = MyFisSpacing.md),
        )
    }
}

@Composable
private fun FieldLabel(text: String) {
    Text(
        text,
        style = MyFisTheme.type.titleSm,
        color = MyFisColor.TextPrimary,
        modifier = Modifier.padding(bottom = MyFisSpacing.md),
    )
}

@Composable
private fun NameField(value: String, onChange: (String) -> Unit) {
    Box(
        Modifier
            .fillMaxWidth()
            .height(MyFisSize.inputHeight)
            .background(MyFisColor.Surface2, MyFisRadius.md)
            .padding(horizontal = MyFisSpacing.lg),
        contentAlignment = Alignment.CenterStart,
    ) {
        BasicTextField(
            value = value,
            onValueChange = onChange,
            singleLine = true,
            textStyle = MyFisTheme.type.body.copy(color = MyFisColor.TextPrimary),
            cursorBrush = SolidColor(MyFisColor.Accent),
            modifier = Modifier.fillMaxWidth(),
            decorationBox = { field ->
                if (value.isEmpty()) {
                    Text(
                        "모임명이 짧을수록 알아보기 쉬워요",
                        style = MyFisTheme.type.body,
                        color = MyFisColor.TextTertiary,
                    )
                }
                field()
            },
        )
    }
}

/**
 * 갈래 칩 + `더보기` / `접기`.
 *
 * **고른 것이 맨 앞으로 온다** (원본과 같다) — 접었을 때도 고른 게 늘 보여야 하고,
 * 안 그러면 접는 순간 무엇을 골랐는지 사라진다.
 */
@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun CategoryChips(
    selected: GroupCategory?,
    expanded: Boolean,
    onSelect: (GroupCategory) -> Unit,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val all = GroupCategory.pickable
    val ordered = if (selected == null) all else listOf(selected) + all.filter { it != selected }
    // 접었을 때 보일 개수. 넷은 한 줄에 안 들어가고 셋이면 `더보기` 까지 한 줄이다
    val shown = if (expanded) ordered else ordered.take(3)

    FlowRow(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        shown.forEach { item ->
            PickChip(item.label, selected = item == selected) { onSelect(item) }
        }
        PickChip(if (expanded) "접기" else "더보기", chevronUp = expanded, onClick = onToggle)
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun RegionChips(selected: String?, onSelect: (String) -> Unit) {
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        // 목록에 없는 동네는 찾아서 고른다 (원본과 같은 자리)
        PickChip("검색", icon = R.drawable.ic_header_search) {}
        groupRegionPlaceholder.forEach { item ->
            PickChip(item, selected = item == selected) { onSelect(item) }
        }
    }
}

/**
 * 고르는 칩.
 *
 * ⚠️ 높이는 `size.chip`(36) 이 아니라 **터치 타겟(48)** 이다 — 물 마시기 시각 칩(§6.22)과 같은 규칙이다.
 * 고른 것은 **판을 채우고 글자를 뒤집는다** (원본과 같다) — 다크에서 가장 셀 수 있는 표시다
 */
@Composable
private fun PickChip(
    label: String,
    selected: Boolean = false,
    /** `더보기` / `접기` 칩만 화살표를 단다. `null` 이면 안 단다 */
    chevronUp: Boolean? = null,
    /** 글자 앞에 붙는 그림. 지역 `검색` 칩만 쓴다 */
    icon: Int? = null,
    onClick: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .height(MyFisSize.minTouchTarget)
            .background(if (selected) MyFisColor.TextPrimary else Color.Transparent, MyFisRadius.full)
            .then(
                if (selected) Modifier
                else Modifier.border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.full),
            )
            .tapWithHaptics(interaction, onClick)
            .padding(horizontal = MyFisSpacing.lg),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        if (icon != null) {
            Icon(
                painter = painterResource(icon),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier.size(16.dp),
            )
        }
        Text(
            label,
            style = MyFisTheme.type.body.copy(
                fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
            ),
            color = if (selected) MyFisColor.OnAccent else MyFisColor.TextSecondary,
        )
        if (chevronUp != null) {
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextSecondary,
                modifier = Modifier
                    .size(14.dp)
                    .rotate(if (chevronUp) 180f else 0f),
            )
        }
    }
}

// MARK: - 모델

/**
 * 활동 지역 자리값 (§6.30) — 지점 동네와 그 옆이다.
 * TODO(서버): 지점 좌표로 가까운 동네를 받아 온다
 */
val groupRegionPlaceholder = listOf("치평동", "화정동", "광천동")
