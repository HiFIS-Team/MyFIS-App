package com.myfis.app.ui.components

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.temporal.TemporalAdjusters

/**
 * DESIGN.md §6.11 주간 캘린더 — 홈 헤더 바로 밑.
 *
 * 이번 주 **월~일 7칸**을 한 줄로 보여주고 하루를 고른다.
 * 선택은 하단 탭과 같은 규칙이다 — **라임을 쓰지 않는다.**
 * 상시 떠 있는 것에 액센트 예산(한 화면 2곳)을 쓰지 않는다 (§6.7).
 *
 * 선택 알약은 칸을 따라 **흐른다.** 칸마다 배경을 껐다 켜면 선택이 순간이동해 보인다.
 */
@Composable
fun WeekCalendar(
    week: List<LocalDate>,
    selected: LocalDate,
    onSelect: (LocalDate) -> Unit,
    modifier: Modifier = Modifier,
) {
    val index = week.indexOf(selected).coerceAtLeast(0)

    BoxWithConstraints(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        val column = maxWidth / DAYS
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
                    onClick = { onSelect(day) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

/** [date] 가 속한 주를 **월요일부터** 7일 반환한다. */
fun weekOf(date: LocalDate): List<LocalDate> {
    val monday = date.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
    return (0 until DAYS).map { monday.plusDays(it.toLong()) }
}

private const val DAYS = 7

/** 칸 하나가 터치 타겟(48)보다 커야 하므로 알약 높이가 곧 행 높이다 */
private val PillHeight = 68.dp
private val PillWidth = 44.dp
private val MarkSize = 26.dp

@Composable
private fun DayCell(
    day: LocalDate,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val interaction = remember { MutableInteractionSource() }
    val motion = MyFisMotion.base<Color>()
    val markBg by animateColorAsState(
        if (selected) MyFisColor.TextPrimary else Color.Transparent, motion, label = "markBg",
    )
    val markFg by animateColorAsState(
        if (selected) MyFisColor.BgBase else MyFisColor.TextTertiary, motion, label = "markFg",
    )
    val dateFg by animateColorAsState(
        if (selected) MyFisColor.TextPrimary else MyFisColor.TextSecondary, motion, label = "dateFg",
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
        Text(
            text = day.dayOfMonth.toString(),
            // 날짜는 자릿수가 바뀌어도 칸 안에서 흔들리면 안 된다 (DESIGN §4.1 tabular)
            style = MyFisTheme.type.titleSm.copy(fontFeatureSettings = "tnum"),
            color = dateFg,
            modifier = Modifier.padding(top = MyFisSpacing.xs),
        )
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
