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
    onNext: (String, GroupCategory, Set<GroupDay>, GroupTimeSlot?) -> Unit = { _, _, _, _ -> },
) {
    var name by rememberSaveable { mutableStateOf("") }
    var category by rememberSaveable { mutableStateOf<GroupCategory?>(null) }
    var days by rememberSaveable { mutableStateOf(setOf<GroupDay>()) }
    var slot by rememberSaveable { mutableStateOf<GroupTimeSlot?>(null) }
    var expanded by rememberSaveable { mutableStateOf(false) }

    /** 이름과 갈래가 있어야 다음이 뜻이 있다 */
    val ready = name.trim().isNotEmpty() && category != null
    /** 질문을 언제까지 띄워 두나 — **이름을 치기 시작하면 물러난다** */
    val asking = name.isEmpty()

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
            if (asking) {
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
            }

            FieldLabel("모임명")
            NameField(name) { name = it }
            CategoryChips(
                selected = category,
                expanded = expanded,
                onSelect = { category = if (category == it) null else it },
                onToggle = { expanded = !expanded },
                modifier = Modifier.padding(top = MyFisSpacing.md),
            )

            // 이름과 갈래가 정해져야 나타난다 — 원본에서 지도가 그렇게 뜬다.
            // 처음부터 다 보이면 **묻는 게 셋**이 되어 첫 칸에 손이 안 간다
            if (ready) {
                Spacer(Modifier.height(MyFisSpacing.xxl))
                FieldLabel("모이는 때")
                DayChips(days) { day ->
                    days = if (day in days) days - day else days + day
                }
                SlotChips(slot, Modifier.padding(top = MyFisSpacing.sm)) {
                    slot = if (slot == it) null else it
                }
            }
        }

        // **바닥에 붙는다.** 다 채우고 누르는 버튼이라 떠 있을 이유가 없다 —
        // 이 화면은 탭 바가 없는 잎이라 §6.28 알약 규칙이 걸리지 않는다
        MyFisPrimaryButton(
            text = "다음",
            onClick = { onNext(name.trim(), category ?: GroupCategory.WEIGHT, days, slot) },
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
private fun DayChips(selected: Set<GroupDay>, onToggle: (GroupDay) -> Unit) {
    FlowRow(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        GroupDay.entries.forEach { day ->
            PickChip(day.label, selected = day in selected, compact = true) { onToggle(day) }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun SlotChips(
    selected: GroupTimeSlot?,
    modifier: Modifier = Modifier,
    onSelect: (GroupTimeSlot) -> Unit,
) {
    FlowRow(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
    ) {
        GroupTimeSlot.entries.forEach { item ->
            PickChip(item.label, selected = item == selected) { onSelect(item) }
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
    /**
     * 한 글자짜리 요일 칩용 — 여백을 한 단계 좁힌다.
     * 넓은 채로 두면 **일곱 개가 한 줄에 안 들어가 `일` 이 혼자 다음 줄로 떨어진다**
     */
    compact: Boolean = false,
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
            .padding(horizontal = if (compact) MyFisSpacing.md else MyFisSpacing.lg),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
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

/** 무슨 요일에 모이나 (SPEC G-03) */
enum class GroupDay(val label: String) {
    MON("월"), TUE("화"), WED("수"), THU("목"), FRI("금"), SAT("토"), SUN("일")
}

/**
 * 하루 중 언제 (SPEC G-03) — 시각을 분 단위로 묻지 않는다.
 * **모임은 대개 "저녁쯤"으로 정해지고**, 분까지 물으면 만들기가 무거워진다
 */
enum class GroupTimeSlot(val label: String) {
    DAWN("새벽"), MORNING("아침"), NOON("점심"), EVENING("저녁"), FREE("자유")
}
