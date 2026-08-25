package com.myfis.app.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.HomeCalendar
import com.myfis.app.ui.shell.AppHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import java.time.LocalDate

/**
 * SPEC.md H-01 홈.
 *
 * 헤더 바로 밑에 **이번 주 캘린더**가 있고, 그 아래가 고른 날의 내용이다.
 * 아직 카드가 없어 자리값만 둔다.
 *
 * **헤더는 셸이 아니라 화면이 들고 있다.** 지점·멤버십·알림 헤더는 홈에서만 쓴다 —
 * 스토어는 검색·장바구니·마이를 쓴다 (DESIGN.md §6.9).
 */
@Composable
fun HomeScreen(
    onNotification: () -> Unit = {},
    onDiet: () -> Unit = {},
    onCardio: () -> Unit = {},
    onWeight: () -> Unit = {},
) {
    val today = remember { LocalDate.now() }

    // LocalDate 는 Saveable 이 아니라 epochDay 로 들고 있는다.
    var selectedEpochDay by rememberSaveable { mutableLongStateOf(today.toEpochDay()) }
    var expanded by rememberSaveable { mutableStateOf(false) }
    // 펼쳤을 때 보고 있는 달. 고른 날과 따로 둔다 — 지난 달을 넘겨봐도 고른 날은 그대로다
    var monthEpochDay by rememberSaveable { mutableLongStateOf(today.withDayOfMonth(1).toEpochDay()) }
    val selected = LocalDate.ofEpochDay(selectedEpochDay)

    Column(Modifier.fillMaxSize()) {
        AppHeader(onNotification = onNotification)
        HomeCalendar(
            selected = selected,
            month = LocalDate.ofEpochDay(monthEpochDay),
            expanded = expanded,
            attended = remember(today) { attendedPlaceholder(today) },
            onSelect = { selectedEpochDay = it.toEpochDay() },
            onMonthChange = { monthEpochDay = it.withDayOfMonth(1).toEpochDay() },
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        CalendarBar(
            expanded = expanded,
            onToggle = { expanded = !expanded },
            streak = attendanceStreakPlaceholder,
            modifier = Modifier.padding(top = MyFisSpacing.xs),
        )
        ShortcutRow(
            onDiet = onDiet,
            onCardio = onCardio,
            modifier = Modifier.padding(top = MyFisSpacing.lg),
        )
        TodayRoutineSection(
            routine = todayRoutinePlaceholder,
            onStart = onWeight,
            modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
        )
        // TODO: 회원권 카드(②) · 마일리지가 아래에 붙는다 (SPEC H-01).
    }
}

/**
 * 홈 바로가기 두 장 (DESIGN.md §6.13).
 *
 * 캘린더 바로 밑 — 고른 날에 **오늘 할 일**로 바로 들어가는 길이다.
 * 두 장으로 고정한다. 늘어나면 홈이 링크 모음이 된다.
 */
@Composable
private fun ShortcutRow(
    onDiet: () -> Unit,
    onCardio: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap),
    ) {
        ShortcutCard(
            icon = R.drawable.ic_home_diet,
            title = "AI 식단 분석",
            subtitle = "사진으로 기록",
            onClick = onDiet,
            modifier = Modifier.weight(1f),
        )
        ShortcutCard(
            icon = R.drawable.ic_tab_cardio,
            title = "유산소",
            subtitle = "스캔하고 시작",
            onClick = onCardio,
            modifier = Modifier.weight(1f),
        )
    }
}

@Composable
private fun ShortcutCard(
    icon: Int,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        // 누름 축소는 **아이콘에만** 준다 (§6.7). 카드가 통째로 움찔거리면 화면이 흔들려 보인다
        modifier = modifier
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .tapWithHaptics(interaction, onClick)
            .padding(MyFisSpacing.cardPadding),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.md),
    ) {
        Icon(
            painter = painterResource(icon),
            contentDescription = null, // 옆 제목이 이름 역할을 한다
            tint = MyFisColor.TextPrimary,
            modifier = Modifier.size(26.dp),
        )
        Column {
            Text(
                title,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                subtitle,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        }
    }
}

/**
 * 캘린더 아래 한 줄 — 왼쪽 `펼쳐보기`, 오른쪽 `연속 출석`.
 *
 * 펼치기는 **화살표가 뒤집히며** 캘린더가 그 달로 늘어난다 (§6.11).
 * 연속 출석은 이 화면에서 **자랑거리**라 숫자만 흰색으로 세운다.
 */
@Composable
private fun CalendarBar(
    expanded: Boolean,
    onToggle: () -> Unit,
    streak: Int,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val arrow by animateFloatAsState(
        targetValue = if (expanded) 180f else 0f,
        animationSpec = MyFisMotion.base(),
        label = "arrow",
    )

    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal - MyFisSpacing.sm),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Row(
            modifier = Modifier
                .clip(MyFisRadius.full)
                .tapWithHaptics(interaction, onToggle)
                // 오른쪽 뱃지와 세로 중심을 맞춘다 (패딩이 다르면 한쪽이 떠 보인다)
                .padding(horizontal = MyFisSpacing.sm, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text(
                if (expanded) "접기" else "펼쳐보기",
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
            )
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                tint = MyFisColor.TextSecondary,
                modifier = Modifier
                    .size(18.dp)
                    .graphicsLayer { rotationZ = arrow },
            )
        }

        Spacer(Modifier.weight(1f))

        // 도장을 모은 결과라 **도장 자체를 뱃지에 넣는다.** 체크 아이콘보다 무슨 숫자인지가 분명해진다
        Row(
            modifier = Modifier
                .padding(horizontal = MyFisSpacing.sm)
                .background(MyFisColor.Surface1, MyFisRadius.full)
                .padding(start = MyFisSpacing.sm, end = MyFisSpacing.md, top = 6.dp, bottom = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.xs),
        ) {
            Image(
                painter = painterResource(R.drawable.ic_stamp),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                // 달력 안에서는 기울여 찍지만, 뱃지에서는 **반듯하게** 둔다 — 여기선 기호에 가깝다
                modifier = Modifier.size(22.dp),
            )
            Text("연속 출석", style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
            Row(verticalAlignment = Alignment.Bottom) {
                Text(
                    streak.toString(),
                    style = MyFisTheme.type.titleMd.copy(fontFeatureSettings = "tnum"),
                    color = MyFisColor.TextPrimary,
                )
                Text(
                    "일",
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextSecondary,
                    modifier = Modifier.padding(start = 1.dp, bottom = 2.dp),
                )
            }
        }
    }
}

/** TODO(서버): 출석 기록이 붙으면 계산한다 */
private const val attendanceStreakPlaceholder = 12

/**
 * TODO(서버): 출석 API 가 붙으면 지운다.
 *
 * 연속 12일(= 위 자리값)과 앞선 며칠. 숫자와 달력이 서로 다른 말을 하면 안 된다.
 */
private fun attendedPlaceholder(today: LocalDate): Set<LocalDate> {
    val streak = (0 until attendanceStreakPlaceholder).map { today.minusDays(it.toLong()) }
    val earlier = listOf(16L, 17L, 20L, 21L).map { today.minusDays(it) }
    return (streak + earlier).toSet()
}

/**
 * 오늘의 루틴 (DESIGN.md §6.14) — 홈에서 **오늘 뭘 하는지** 한 장으로 보여주고 웨이트로 보낸다.
 *
 * 루틴은 AI가 짜서 보낸다. 사용자가 만들거나 고르지 않으므로
 * 섹션에 `새 루틴` 같은 액션을 두지 않는다 — 목록이 아니라 오늘 한 장이다.
 */
@Composable
private fun TodayRoutineSection(
    routine: TodayRoutine,
    onStart: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        Text("오늘의 루틴", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.height(MyFisSpacing.md))
        RoutineCard(routine = routine, onStart = onStart)
    }
}

@Composable
private fun RoutineCard(routine: TodayRoutine, onStart: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // 카드 전체가 웨이트로 가는 길이다. 아래 [웨이트 하러 가기] 는 그 길을 보여주는 표시다
        modifier = Modifier
            .fillMaxWidth()
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .tapWithHaptics(interaction, onStart)
            .padding(MyFisSpacing.cardPadding),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                routine.name,
                style = MyFisTheme.type.titleSm,
                color = MyFisColor.TextPrimary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f, fill = false),
            )
            Spacer(Modifier.weight(1f))
            Text(routine.week, style = MyFisTheme.type.caption, color = MyFisColor.TextTertiary)
        }

        Spacer(Modifier.height(MyFisSpacing.lg))

        Row(verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.sm),
                ) {
                    Text(
                        "Day ${routine.day}",
                        style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                        color = MyFisColor.TextPrimary,
                    )
                    Text(
                        routine.focus,
                        style = MyFisTheme.type.body,
                        color = MyFisColor.TextSecondary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
                Spacer(Modifier.height(2.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        "${routine.exerciseCount}개",
                        style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                        color = MyFisColor.TextTertiary,
                    )
                    // 구분은 점이 아니라 **세로선**이다 (§6.12 상품 메타와 같은 규칙)
                    Box(
                        Modifier
                            .padding(horizontal = MyFisSpacing.sm)
                            .size(width = 1.dp, height = 10.dp)
                            .background(MyFisColor.BorderStrong),
                    )
                    Text(
                        "${routine.firstExercise} 외",
                        style = MyFisTheme.type.bodySm,
                        color = MyFisColor.TextTertiary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
            }
            Spacer(Modifier.size(MyFisSpacing.md))
            WeekProgressRing(done = routine.doneDays, total = routine.totalDays)
        }

        Spacer(Modifier.height(MyFisSpacing.lg))

        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(2.dp),
        ) {
            Text("웨이트 하러 가기", style = MyFisTheme.type.titleSm, color = MyFisColor.Accent)
            Icon(
                painter = painterResource(R.drawable.ic_chevron_down),
                contentDescription = null, // 옆 글자가 이름 역할을 한다
                tint = MyFisColor.Accent,
                // 오른쪽 화살표는 따로 두지 않고 아래 화살표를 돌려 쓴다 (같은 획, 같은 굵기)
                modifier = Modifier
                    .size(18.dp)
                    .graphicsLayer { rotationZ = -90f },
            )
        }
    }
}

/**
 * 이번 주 진행률 링.
 *
 * 액센트는 이 카드에서 **[웨이트 하러 가기] 하나만** 쓴다 (§2 원칙 3).
 * 링까지 라임이면 어디를 눌러야 하는지가 흐려진다.
 */
@Composable
private fun WeekProgressRing(done: Int, total: Int) {
    val ratio = if (total <= 0) 0f else done.toFloat() / total

    Box(Modifier.size(RingSize), contentAlignment = Alignment.Center) {
        Canvas(Modifier.fillMaxSize()) {
            val stroke = RingStroke.toPx()
            val topLeft = Offset(stroke / 2, stroke / 2)
            val arcSize = Size(size.width - stroke, size.height - stroke)
            drawArc(
                color = MyFisColor.BorderSubtle,
                startAngle = 0f,
                sweepAngle = 360f,
                useCenter = false,
                topLeft = topLeft,
                size = arcSize,
                style = Stroke(stroke),
            )
            drawArc(
                color = MyFisColor.TextPrimary,
                startAngle = -90f, // 12시부터 시계방향
                sweepAngle = 360f * ratio,
                useCenter = false,
                topLeft = topLeft,
                size = arcSize,
                style = Stroke(stroke, cap = StrokeCap.Round),
            )
        }
        Text(
            "$done/$total",
            style = MyFisTheme.type.label.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
        )
    }
}

private val RingSize = 56.dp
private val RingStroke = 4.dp

/** TODO(서버): `WeeklyRoutine` · `RoutineDay` 가 붙으면 지운다 (SPEC W-01) */
private data class TodayRoutine(
    val name: String,
    val week: String,
    val day: Int,
    val focus: String,
    val exerciseCount: Int,
    val firstExercise: String,
    val doneDays: Int,
    val totalDays: Int,
)

/** TODO(서버): 주간 루틴 API 가 붙으면 지운다 */
private val todayRoutinePlaceholder = TodayRoutine(
    name = "체지방 감량 4주 루틴",
    week = "8월 4주차",
    day = 3,
    focus = "가슴 · 삼두",
    exerciseCount = 5,
    firstExercise = "벤치프레스",
    doneDays = 2,
    totalDays = 5,
)
