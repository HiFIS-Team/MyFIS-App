package com.myfis.app.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
import com.myfis.app.ui.theme.tapWithHaptics
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters

/**
 * DESIGN.md §6.11 홈 캘린더 — 헤더 바로 밑.
 *
 * 평소에는 **이번 주 한 줄**, `펼쳐보기` 를 누르면 **그 달 전체**로 늘어난다.
 * 선택은 하단 탭과 같은 규칙이다 — **라임을 쓰지 않는다.**
 * 상시 떠 있는 것에 액센트 예산(한 화면 2곳)을 쓰지 않는다 (§6.7).
 */
@Composable
fun HomeCalendar(
    selected: LocalDate,
    /** 펼쳤을 때 보이는 달 (그 달의 아무 날) */
    month: LocalDate,
    expanded: Boolean,
    attended: Set<LocalDate>,
    onSelect: (LocalDate) -> Unit,
    onMonthChange: (LocalDate) -> Unit,
    modifier: Modifier = Modifier,
) {
    // 높이만 줄이면 **내용이 먼저 사라지고 빈칸이 뒤늦게 닫힌다** — 아래 줄이 늦게 따라오는 것처럼 보인다.
    // 접힐 때도 내용과 높이가 같이 움직이도록 `AnimatedVisibility` 로 감싼다.
    Column(modifier.fillMaxWidth()) {
        AnimatedVisibility(
            visible = !expanded,
            enter = expandVertically(MyFisMotion.slow()) + fadeIn(MyFisMotion.slow()),
            exit = shrinkVertically(MyFisMotion.slow()) + fadeOut(MyFisMotion.slow()),
        ) {
            WeekStrip(
                week = weekOf(selected),
                selected = selected,
                attended = attended,
                onSelect = onSelect,
            )
        }
        AnimatedVisibility(
            visible = expanded,
            enter = expandVertically(MyFisMotion.slow()) + fadeIn(MyFisMotion.slow()),
            exit = shrinkVertically(MyFisMotion.slow()) + fadeOut(MyFisMotion.slow()),
        ) {
            Column {
                MonthHeader(
                    month = month,
                    onPrev = { onMonthChange(month.minusMonths(1)) },
                    onNext = { onMonthChange(month.plusMonths(1)) },
                )
                WeekdayHeader()
                monthWeeks(month).forEach { week ->
                    MonthRow(
                        week = week,
                        selected = selected,
                        attended = attended,
                        onSelect = onSelect,
                    )
                }
            }
        }
    }
}

/** 접힌 상태 — 요일과 날짜가 한 칸에 있고, 고른 칸만 알약이 채워진다 */
@Composable
private fun WeekStrip(
    week: List<LocalDate>,
    selected: LocalDate,
    attended: Set<LocalDate>,
    onSelect: (LocalDate) -> Unit,
) {
    val index = week.indexOf(selected).coerceAtLeast(0)

    BoxWithConstraints(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        val column = maxWidth / DAYS
        // 알약은 칸을 따라 **흐른다.** 칸마다 배경을 껐다 켜면 선택이 순간이동해 보인다
        val pillX by animateDpAsState(
            targetValue = column * index + (column - PillWidth) / 2,
            animationSpec = MyFisMotion.base(),
            label = "pillX",
        )

        Box(
            Modifier
                .offset(x = pillX)
                .size(width = PillWidth, height = PillHeight)
                .background(MyFisColor.Surface2, MyFisRadius.full),
        )

        Row(Modifier.fillMaxWidth()) {
            week.forEach { day ->
                DayCell(
                    day = day,
                    selected = day == selected,
                    attended = day in attended,
                    onClick = { onSelect(day) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

/** 펼친 상태의 달 머리글 — `2026년 8월` 과 앞뒤 달로 가는 화살표 */
@Composable
private fun MonthHeader(month: LocalDate, onPrev: () -> Unit, onNext: () -> Unit) {
    Row(
        Modifier
            .fillMaxWidth()
            .padding(
                start = MyFisSpacing.screenHorizontal,
                end = MyFisSpacing.screenHorizontal - MyFisSpacing.sm,
                bottom = MyFisSpacing.md,
            ),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text(
            "${month.year}년 ${month.monthValue}월",
            style = MyFisTheme.type.titleMd.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextPrimary,
        )
        Spacer(Modifier.weight(1f))
        // 화살표는 아래쪽 화살표 한 벌을 돌려 쓴다 (§6.11)
        MonthArrow(rotation = 90f, description = "이전 달", onClick = onPrev)
        MonthArrow(rotation = -90f, description = "다음 달", onClick = onNext)
    }
}

@Composable
private fun MonthArrow(rotation: Float, description: String, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }
    val press by interaction.pressScale()

    Box(
        Modifier
            .size(40.dp)
            .clip(MyFisRadius.full)
            .tapWithHaptics(interaction, onClick),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            painter = painterResource(R.drawable.ic_chevron_down),
            contentDescription = description,
            tint = MyFisColor.TextSecondary,
            modifier = Modifier
                .size(20.dp)
                .graphicsLayer {
                    rotationZ = rotation
                    scaleX = press
                    scaleY = press
                },
        )
    }
}

/** 펼친 상태의 요일 머리글 — 칸마다 요일을 반복하면 달력이 시끄럽다 */
/**
 * 토요일 파랑 · 일요일 빨강 — 한국 달력 관행 (DESIGN.md §3.1).
 * 고른 날은 흰 알약/원이 더 센 신호라 그쪽을 따른다.
 */
private val DayOfWeek.weekendColor: Color?
    get() = when (this) {
        DayOfWeek.SATURDAY -> MyFisColor.WeekendSaturday
        DayOfWeek.SUNDAY -> MyFisColor.WeekendSunday
        else -> null
    }

@Composable
private fun WeekdayHeader() {
    Row(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        weekdayOrder.forEach { day ->
            Text(
                day.koLabel,
                style = MyFisTheme.type.caption,
                color = day.weekendColor ?: MyFisColor.TextTertiary,
                textAlign = TextAlign.Center,
                modifier = Modifier
                    .weight(1f)
                    .padding(bottom = MyFisSpacing.xs),
            )
        }
    }
}

/** 펼친 상태의 한 주 — 날짜만 있고, 고른 날은 흰 원이다 */
@Composable
private fun MonthRow(
    week: List<LocalDate?>,
    selected: LocalDate,
    attended: Set<LocalDate>,
    onSelect: (LocalDate) -> Unit,
) {
    Row(
        Modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        week.forEach { day ->
            Box(Modifier.weight(1f).height(50.dp), contentAlignment = Alignment.Center) {
                if (day != null) MonthDay(day, day == selected, day in attended) { onSelect(day) }
            }
        }
    }
}

@Composable
private fun MonthDay(
    day: LocalDate,
    selected: Boolean,
    attended: Boolean,
    onClick: () -> Unit,
) {
    val interaction = remember { MutableInteractionSource() }
    val dateFg by animateColorAsState(
        if (selected) MyFisColor.TextPrimary else day.dayOfWeek.weekendColor ?: MyFisColor.TextSecondary,
        MyFisMotion.base(),
        label = "monthFg",
    )

    Column(
        modifier = Modifier.tapWithHaptics(interaction, onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(Modifier.size(StampSize), contentAlignment = Alignment.Center) {
            Text(
                day.dayOfMonth.toString(),
                style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
                color = dateFg,
            )
            // 도장은 **숫자 위**에 온다 — 달력에 찍은 자국이라 겹치는 게 맞다
            if (attended) Stamp(day)
        }
        // 고른 날은 **동그라미 대신 밑에 점**이다. 도장과 겹치지 않고, 달력이 조용해진다
        Box(
            Modifier
                .size(DotSize)
                .background(
                    if (selected) MyFisColor.TextPrimary else Color.Transparent,
                    CircleShape,
                ),
        )
    }
}

/** [date] 가 속한 주를 **일요일부터** 7일 반환한다 (한국 달력 관행). */
fun weekOf(date: LocalDate): List<LocalDate> {
    val sunday = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY))
    return (0 until DAYS).map { sunday.plusDays(it.toLong()) }
}

/**
 * [date] 가 속한 **달**을 주 단위로 자른다. 앞뒤 빈 칸은 `null` 이다.
 *
 * 옆 달 날짜를 흐리게 채우지 않는다 — 이 달 안에서만 고르게 한다.
 */
fun monthWeeks(date: LocalDate): List<List<LocalDate?>> {
    val first = date.withDayOfMonth(1)
    // 일요일이 첫 칸이다. `DayOfWeek.SUNDAY.value` 는 7 이라 그대로 나머지 연산에 쓴다
    val lead = first.dayOfWeek.value % DAYS
    val days: List<LocalDate?> = List(lead) { null } +
        (1..date.lengthOfMonth()).map { first.withDayOfMonth(it) }
    val padded = days + List((DAYS - days.size % DAYS) % DAYS) { null }
    return padded.chunked(DAYS)
}

private const val DAYS = 7

/** 칸 하나가 터치 타겟(48)보다 커야 하므로 알약 높이가 곧 행 높이다 */
private val PillHeight = 68.dp
private val PillWidth = 44.dp
private val MarkSize = 26.dp

/** 출석 도장이 날짜를 감싸는 크기 */
private val StampSize = 40.dp

/** 고른 날 표시 — 날짜 밑 점 */
private val DotSize = 5.dp

/**
 * 출석 도장 — 우리 로고 도장 그대로다.
 *
 * **숫자 위에 겹쳐 찍는다.** 종이 달력에 도장을 찍은 자국이라 겹치는 게 의도다
 * (며칠인지는 칸 위치로도 읽힌다).
 * 색이 있는 그림이라 `Icon`(tint)이 아니라 `Image` 로 그린다.
 */
@Composable
private fun Stamp(day: LocalDate) {
    Image(
        painter = painterResource(R.drawable.ic_stamp),
        contentDescription = null, // 출석 여부는 화면 낭독에서 날짜와 함께 읽히면 된다
        modifier = Modifier
            .size(StampSize)
            .graphicsLayer { rotationZ = day.stampAngle() },
    )
}

/**
 * 진짜 도장은 삐뚤게 찍힌다. 날짜에서 각도를 뽑아 **-10°~+10°** 로 기울인다.
 *
 * 무작위가 아니라 **날짜에서 계산**한다 — 다시 그릴 때마다 각도가 바뀌면 화면이 들썩인다.
 * 두 플랫폼이 같은 식을 쓰므로 같은 날은 같은 각도다.
 */
private fun LocalDate.stampAngle(): Float =
    ((dayOfMonth * 37 + monthValue * 13) % 21 - 10).toFloat()

private val weekdayOrder = listOf(
    DayOfWeek.SUNDAY, DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY,
    DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY,
)

@Composable
private fun DayCell(
    day: LocalDate,
    selected: Boolean,
    attended: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val motion = MyFisMotion.base<Color>()
    val markBg by animateColorAsState(
        if (selected) MyFisColor.TextPrimary else Color.Transparent, motion, label = "markBg",
    )
    val weekend = day.dayOfWeek.weekendColor
    val markFg by animateColorAsState(
        if (selected) MyFisColor.BgBase else weekend ?: MyFisColor.TextTertiary, motion, label = "markFg",
    )
    val dateFg by animateColorAsState(
        if (selected) MyFisColor.TextPrimary else weekend ?: MyFisColor.TextSecondary, motion, label = "dateFg",
    )

    Column(
        modifier = modifier
            .height(PillHeight)
            .tapWithHaptics(interaction, onClick),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
    ) {
        Box(
            Modifier.size(MarkSize).background(markBg, CircleShape),
            contentAlignment = Alignment.Center,
        ) {
            Text(day.dayOfWeek.koLabel, style = MyFisTheme.type.caption, color = markFg)
        }
        Box(
            Modifier
                .padding(top = MyFisSpacing.xs)
                .size(StampSize),
            contentAlignment = Alignment.Center,
        ) {
            Text(
                text = day.dayOfMonth.toString(),
                // 날짜는 자릿수가 바뀌어도 칸 안에서 흔들리면 안 된다 (DESIGN §4.1 tabular)
                style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
                color = dateFg,
            )
            // 도장은 **숫자 위**에 온다 — 달력에 찍은 자국이라 겹치는 게 맞다
            if (attended) Stamp(day)
        }
    }
}

/**
 * 기기 로케일을 따르지 않고 우리가 정한다 — 한국어 전용 앱이고,
 * 요일 한 글자는 폭이 일정해야 칸이 흔들리지 않는다.
 */
private val DayOfWeek.koLabel: String
    get() = when (this) {
        DayOfWeek.MONDAY -> "월"
        DayOfWeek.TUESDAY -> "화"
        DayOfWeek.WEDNESDAY -> "수"
        DayOfWeek.THURSDAY -> "목"
        DayOfWeek.FRIDAY -> "금"
        DayOfWeek.SATURDAY -> "토"
        DayOfWeek.SUNDAY -> "일"
    }
