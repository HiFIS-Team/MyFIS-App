package com.myfis.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.MileageChip
import com.myfis.app.ui.theme.MyFisCard
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisIconTile
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisPrimaryButton
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSmallButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics

// ── 모델 ──────────────────────────────────────────────
//
// TODO(서버): 주간 루틴 API (SPEC §8) 가 붙으면 이 자리를 받아온 값으로 채운다.

/** 그 운동을 하는 **구역** — M-08 기구 찾기가 나누는 넷과 같은 단위다 (§6.26) */
enum class RoutineGear(val icon: Int) {
    FREE(R.drawable.ic_place_free),
    MACHINE(R.drawable.ic_place_machine),
    STRETCH(R.drawable.ic_benefit_stretch),
}

/** 오늘 루틴의 운동 한 줄 */
data class RoutineExercise(
    val id: Int,
    val name: String,
    val gear: RoutineGear,
    val sets: Int,
    /** `20kg` · 맨몸이면 `null` */
    val load: String?,
    val reps: Int,
) {
    /** `4세트 × 20kg × 12회` — SPEC W-02 표기. 곱하기 기호는 SPEC 을 따른다 */
    val prescription: String
        get() = listOfNotNull("${sets}세트", load, "${reps}회").joinToString(" × ")
}

/** 이번 주 띠의 한 칸 */
data class RoutineDay(
    val weekday: String,
    /** 그날의 부위. 쉬는 날은 `휴식` */
    val focus: String,
    val rest: Boolean,
    val done: Boolean,
    val today: Boolean,
)

/** TODO(서버): 아래 전부 자리 표시다 (SPEC W-01) */
private val routineWeekPlaceholder = listOf(
    RoutineDay("일", "휴식", rest = true, done = false, today = false),
    RoutineDay("월", "등", rest = false, done = true, today = false),
    RoutineDay("화", "하체", rest = false, done = true, today = false),
    RoutineDay("수", "휴식", rest = true, done = false, today = false),
    RoutineDay("목", "어깨", rest = false, done = true, today = false),
    RoutineDay("금", "가슴", rest = false, done = false, today = true),
    RoutineDay("토", "팔", rest = false, done = false, today = false),
)

private val routineWarmupPlaceholder =
    listOf("목 돌리기", "어깨 돌리기", "가슴 열기", "팔 돌리기", "손목 풀기")
private const val ROUTINE_WARMUP_MINUTES = 6

private val routineExercisesPlaceholder = listOf(
    RoutineExercise(1, "스미스 머신 벤치 프레스", RoutineGear.MACHINE, 4, "20kg", 12),
    RoutineExercise(2, "인클라인 덤벨 프레스", RoutineGear.FREE, 3, "10kg", 12),
    RoutineExercise(3, "체스트 프레스 머신", RoutineGear.MACHINE, 3, "25kg", 15),
    RoutineExercise(4, "케이블 크로스오버", RoutineGear.MACHINE, 3, "7.5kg", 15),
    RoutineExercise(5, "딥스", RoutineGear.FREE, 3, null, 10),
    RoutineExercise(6, "케이블 푸시다운", RoutineGear.MACHINE, 3, "15kg", 15),
)

/** 오늘 쓸 수 있는 시간 — 고르면 서버가 분량을 맞춰 다시 짠다 */
private val routineMinuteOptions = listOf(30, 45, 60, 75, 90)
/** 오늘 몸 상태. 낮추면 세트·중량이 내려간다 */
private val routineConditionOptions = listOf(100, 80, 60, 40)

// ── 화면 ──────────────────────────────────────────────

/**
 * SPEC.md W-01 웨이트 탭 — **오늘의 루틴** (DESIGN.md §6.33).
 *
 * 레퍼런스는 사용자가 준 다른 앱의 `오늘의 추천 운동` 화면이다.
 * **뼈대만 가져오고 표면은 우리 것으로 다시 짠다** (§3.2) —
 * 원본은 운동마다 3D 근육 렌더에 민트를 칠해 **색이 여덟 곳**이지만
 * 우리는 액센트가 화면당 두 곳이라 **알약 하나**에만 쓴다. 위계는 표면 밝기로 세운다 (§5.4).
 *
 * **썸네일이 말하는 것도 바꿨다** — 원본은 *어느 근육*, 우리는 **어느 구역의 기구**다.
 * 초보자가 헬스장에서 실제로 막히는 지점은 근육 이름이 아니라 *그 기구가 어디 있나*이고,
 * 그 답은 M-08 기구 찾기가 이미 들고 있다 (§6.26 과 같은 넷으로 나눈다).
 *
 * **SPEC 의 W-01(이번 주)과 W-02(오늘)를 한 장으로 합쳤다** 🟢 (2026-09-04, 사용자 지정) —
 * 주간 목록만 있는 화면은 §6.28 유산소에서 이미 한 번 걸린 함정이다. *다 본 뒤에 할 일이 없다.*
 * 주차는 맨 위 **요일 일곱 칸 띠**로 압축하고 본문은 오늘 할 것에 준다.
 */
@Composable
fun WeightScreen() {
    // 순서를 바꾸므로 화면이 들고 있는다. TODO(서버): 바뀐 순서를 올린다
    val exercises = remember { mutableStateListOf(*routineExercisesPlaceholder.toTypedArray()) }
    var warmupOpen by rememberSaveable { mutableStateOf(false) }
    var reordering by rememberSaveable { mutableStateOf(false) }
    var minutes by rememberSaveable { mutableStateOf(60) }
    var condition by rememberSaveable { mutableStateOf(100) }

    Column(Modifier.fillMaxSize()) {
        WeightHeader()

        Box(Modifier.weight(1f)) {
            Column(
                modifier = Modifier
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = MyFisSpacing.screenHorizontal)
                    // 알약이 마지막 줄을 가리지 않게 그만큼 비워 둔다 (§6.28 과 같은 값)
                    .padding(bottom = MyFisSize.buttonSecondary + MyFisSpacing.xxxl),
            ) {
                WeekStrip(routineWeekPlaceholder)
                ConditionRow(
                    minutes = minutes,
                    onMinutes = { minutes = it },
                    condition = condition,
                    onCondition = { condition = it },
                    modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
                )
                ListHeader(
                    count = exercises.size + 1,
                    reordering = reordering,
                    onToggle = {
                        reordering = !reordering
                        if (reordering) warmupOpen = false
                    },
                    modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
                )

                Column(Modifier.padding(top = MyFisSpacing.sm)) {
                    // 웜업은 순서를 바꾸는 대상이 아니다 — 몸을 푸는 게 먼저라서 늘 맨 앞이다.
                    // 순서 모드에서는 아예 빼서 **번호가 운동만 세게** 한다
                    if (!reordering) {
                        WarmupRow(open = warmupOpen, onToggle = { warmupOpen = !warmupOpen })
                        RowDivider()
                    }
                    exercises.forEachIndexed { index, item ->
                        ExerciseRow(
                            item = item,
                            index = index,
                            reordering = reordering,
                            last = index == exercises.lastIndex,
                            onUp = { if (index > 0) exercises.add(index - 1, exercises.removeAt(index)) },
                            onDown = {
                                if (index < exercises.lastIndex) {
                                    exercises.add(index + 1, exercises.removeAt(index))
                                }
                            },
                        )
                        if (index < exercises.lastIndex) RowDivider()
                    }
                }
            }

            // 이 화면의 액션은 이 하나뿐 (§2 원칙 5). 폭을 다 쓰면 떠 있는 탭 바와
            // 둥근 덩어리가 둘로 겹치므로 **알약**으로 맞춘다 (§6.28)
            MyFisPrimaryButton(
                text = "운동 시작",
                onClick = {},
                pill = true,
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(end = MyFisSpacing.screenHorizontal, bottom = MyFisSpacing.md),
            )
            // TODO(W-04): `운동 시작` 이 세션으로 넘어간다
        }
    }
}

/** 유산소(§6.28) · 모임(§6.29) 과 같은 꼴 — **화면 이름 한 줄 + 마일리지 칩** */
@Composable
private fun WeightHeader() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(MyFisSize.header)
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("웨이트", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.weight(1f))
        MileageChip(balance = benefitBalancePlaceholder)
    }
}

/**
 * 요일 일곱 칸 — SPEC W-01 의 요일 카드 7장을 **한 줄로 압축한 것**이다.
 *
 * **라임을 쓰지 않는다.** 홈 캘린더(§6.11)와 같은 이유로, 늘 떠 있는 것에
 * 액센트 예산을 쓰지 않는다. 오늘은 `surface.2`, 이미 한 날은 `surface.1` —
 * 위계를 **표면 밝기**로 세운다 (§5.4).
 */
@Composable
private fun WeekStrip(days: List<RoutineDay>) {
    Column(verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("이번 주", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
            Spacer(Modifier.weight(1f))
            Text(
                "${days.count { it.done }} / ${days.count { !it.rest }}일 완료",
                style = MyFisTheme.type.label,
                color = MyFisColor.TextTertiary,
            )
        }
        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs)) {
            days.forEach { WeekCell(it, Modifier.weight(1f)) }
        }
    }
}

/**
 * 한 칸 — 요일 · 부위 · 완료 자국.
 *
 * 완료 자국은 **자리를 늘 비워 둔다.** 있는 칸만 높아지면 띠가 들쭉날쭉해진다.
 * 오늘만 테두리를 두른다 — 표면 밝기 한 단계 차이로는 완료한 날과 잘 안 갈린다 (§6.2)
 */
@Composable
private fun WeekCell(day: RoutineDay, modifier: Modifier = Modifier) {
    val fill = when {
        day.today -> MyFisColor.Surface2
        day.done -> MyFisColor.Surface1
        else -> Color.Transparent
    }
    val focusColor = when {
        day.today -> MyFisColor.TextPrimary
        day.rest -> MyFisColor.TextTertiary
        else -> MyFisColor.TextSecondary
    }
    val weekdayColor = when {
        day.today -> MyFisColor.TextSecondary
        day.weekday == "토" -> MyFisColor.WeekendSaturday
        day.weekday == "일" -> MyFisColor.WeekendSunday
        else -> MyFisColor.TextTertiary
    }

    Column(
        modifier = modifier
            .background(fill, MyFisRadius.md)
            .then(
                if (day.today) Modifier.border(1.dp, MyFisColor.BorderStrong, MyFisRadius.md)
                else Modifier,
            )
            .padding(vertical = MyFisSpacing.md),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
    ) {
        Text(day.weekday, style = MyFisTheme.type.caption, color = weekdayColor)
        Text(
            day.focus,
            style = MyFisTheme.type.label,
            color = focusColor,
            maxLines = 1,
            overflow = TextOverflow.Clip,
            textAlign = TextAlign.Center,
        )
        Icon(
            painter = painterResource(R.drawable.ic_check),
            contentDescription = null,
            tint = if (day.done) MyFisColor.TextTertiary else Color.Transparent,
            modifier = Modifier.size(12.dp),
        )
    }
}

/**
 * 오늘의 조건 두 칸 — 고치면 **분량이 다시 짜인다**.
 *
 * 원본은 칸마다 아이콘을 달았지만 우리는 **글자만 둔다** —
 * `시계`·`번개` 는 28px 에서 다른 뜻으로 읽히기 쉬운 그림이고(§8),
 * 두 글자짜리 라벨이 이미 충분히 짧다.
 */
@Composable
private fun ConditionRow(
    minutes: Int,
    onMinutes: (Int) -> Unit,
    condition: Int,
    onCondition: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier, horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
        SelectorCard("운동 시간", minutes, routineMinuteOptions, { "${it}분" }, onMinutes, Modifier.weight(1f))
        SelectorCard("컨디션", condition, routineConditionOptions, { "${it}%" }, onCondition, Modifier.weight(1f))
    }
}

/** 라벨 위 · 값 아래 — 숫자 카드(§6.3)와 같은 읽는 순서다. 누르면 목록이 뜬다 */
@Composable
private fun SelectorCard(
    label: String,
    value: Int,
    options: List<Int>,
    format: (Int) -> String,
    onPick: (Int) -> Unit,
    modifier: Modifier = Modifier,
) {
    var open by remember { mutableStateOf(false) }
    val interaction = remember { MutableInteractionSource() }

    Box(modifier) {
        MyFisCard(Modifier.tapWithHaptics(interaction) { open = true }) {
            Text(label, style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
            Row(
                modifier = Modifier.fillMaxWidth().padding(top = MyFisSpacing.xs),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(format(value), style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
                Spacer(Modifier.weight(1f))
                Icon(
                    painter = painterResource(R.drawable.ic_chevron_down),
                    contentDescription = null,
                    tint = MyFisColor.TextTertiary,
                    modifier = Modifier.size(18.dp),
                )
            }
        }
        // TODO(서버): 값이 바뀌면 그 조건으로 루틴을 다시 받아온다
        DropdownMenu(
            expanded = open,
            onDismissRequest = { open = false },
            containerColor = MyFisColor.Surface2,
            shape = MyFisRadius.md,
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = {
                        Text(
                            format(option),
                            style = MyFisTheme.type.body,
                            color = if (option == value) MyFisColor.TextPrimary else MyFisColor.TextTertiary,
                        )
                    },
                    onClick = { onPick(option); open = false },
                )
            }
        }
    }
}

/**
 * `총 n개` ↔ `순서 변경`.
 *
 * **슈퍼세트는 두지 않았다** 🟢 (2026-09-04, 사용자 지정) — 두 운동을 쉬지 않고 묶는 건
 * 중급자 개념이고, 우리 타깃은 *기구를 거의 안 써 본* 회원이다 (SPEC `BEGINNER`).
 */
@Composable
private fun ListHeader(
    count: Int,
    reordering: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text("총 ${count}개", style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
        Spacer(Modifier.weight(1f))
        MyFisSmallButton(text = if (reordering) "완료" else "순서 변경", onClick = onToggle)
    }
}

/** 구분선은 **좌측 인덴트 없이 전체 너비**다 (§6.5) */
@Composable
private fun RowDivider() {
    Box(Modifier.fillMaxWidth().height(1.dp).background(MyFisColor.BorderSubtle))
}

/** 웜업 — 스트레칭 다섯 개는 **접어 둔다.** 펴 보는 사람만 보면 되는 목록이다 */
@Composable
private fun WarmupRow(open: Boolean, onToggle: () -> Unit) {
    val turn by animateFloatAsState(if (open) 180f else 0f, MyFisMotion.base(), label = "warmup")
    val interaction = remember { MutableInteractionSource() }

    Column {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .tapWithHaptics(interaction, onToggle)
                .padding(vertical = MyFisSpacing.md)
                .defaultMinSize(minHeight = MyFisSize.listRowMin),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            MyFisIconTile(dimmed = true) {
                Icon(
                    painter = painterResource(RoutineGear.STRETCH.icon),
                    contentDescription = null,
                    tint = MyFisColor.TextSecondary,
                    modifier = Modifier.size(24.dp),
                )
            }
            Column(
                modifier = Modifier.weight(1f).padding(horizontal = MyFisSpacing.md),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
            ) {
                Text("웜업 스트레칭", style = MyFisTheme.type.titleSm, color = MyFisColor.TextPrimary)
                Text(
                    "${routineWarmupPlaceholder.size}개 · ${ROUTINE_WARMUP_MINUTES}분",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextSecondary,
                )
            }
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null,
                tint = MyFisColor.TextTertiary,
                modifier = Modifier.size(20.dp).rotate(turn),
            )
        }

        AnimatedVisibility(open) {
            Column(
                // 글자를 위 줄의 이름과 맞춰 세운다 — 타일 `56` + 사이 `12`
                modifier = Modifier.padding(
                    start = MyFisSize.listRowMin + MyFisSpacing.md,
                    bottom = MyFisSpacing.md,
                ),
                verticalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
            ) {
                routineWarmupPlaceholder.forEach {
                    Text(it, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
                }
            }
        }
    }
}

/**
 * 운동 한 줄. 순서 모드에서는 **타일·처방이 빠지고 번호와 화살표만 남는다** —
 * 순서를 바꿀 때 필요한 건 이름뿐이고, 화살표는 `48` 을 확보해야 한다 (§5.3)
 */
@Composable
private fun ExerciseRow(
    item: RoutineExercise,
    index: Int,
    reordering: Boolean,
    last: Boolean,
    onUp: () -> Unit,
    onDown: () -> Unit,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = MyFisSpacing.md)
            .defaultMinSize(minHeight = MyFisSize.listRowMin),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (reordering) {
            Text(
                "${index + 1}",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                textAlign = TextAlign.Center,
                modifier = Modifier.width(20.dp),
            )
        } else {
            MyFisIconTile {
                Icon(
                    painter = painterResource(item.gear.icon),
                    contentDescription = null,
                    tint = MyFisColor.TextSecondary,
                    modifier = Modifier.size(24.dp),
                )
            }
        }

        Column(
            modifier = Modifier.weight(1f).padding(horizontal = MyFisSpacing.md),
            verticalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Text(
                item.name,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            // 세트·중량·횟수는 자릿수가 바뀌어도 안 흔들려야 한다 (SPEC W 공통)
            if (!reordering) {
                Text(item.prescription, style = MyFisTheme.type.bodySm, color = MyFisColor.TextSecondary)
            }
        }

        if (reordering) {
            // 갈 곳이 없는 화살표는 **색으로 죽인다** — 투명도를 쓰지 않는다 (§9 이탈 #2)
            MoveArrow(180f, enabled = index > 0, onClick = onUp)
            MoveArrow(0f, enabled = !last, onClick = onDown)
        }
        // TODO(W-03): 행을 누르면 시연 영상이 있는 운동 상세로 간다
    }
}

@Composable
private fun MoveArrow(turn: Float, enabled: Boolean, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    Box(
        modifier = Modifier
            .size(MyFisSize.minTouchTarget)
            .then(if (enabled) Modifier.tapWithHaptics(interaction, onClick) else Modifier),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_chevron_down),
            contentDescription = null,
            tint = if (enabled) MyFisColor.TextSecondary else MyFisColor.BorderSubtle,
            modifier = Modifier.size(20.dp).rotate(turn),
        )
    }
}
