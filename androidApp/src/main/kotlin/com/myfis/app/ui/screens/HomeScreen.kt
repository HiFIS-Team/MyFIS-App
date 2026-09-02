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
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.HomeCalendar
import com.myfis.app.ui.components.MileageText
import com.myfis.app.ui.shell.AppHeader
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisMotion
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.tapWithHaptics
import java.time.LocalDate
import java.time.LocalTime

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
    /** M-01 지점 선택 — 헤더 핀 */
    onBranch: () -> Unit = {},
    onNotification: () -> Unit = {},
    onDiet: () -> Unit = {},
    onCardio: () -> Unit = {},
    onWeight: () -> Unit = {},
    onStore: () -> Unit = {},
    onNews: () -> Unit = {},
) {
    val today = remember { LocalDate.now() }

    // LocalDate 는 Saveable 이 아니라 epochDay 로 들고 있는다.
    var selectedEpochDay by rememberSaveable { mutableLongStateOf(today.toEpochDay()) }
    var expanded by rememberSaveable { mutableStateOf(false) }
    // 펼쳤을 때 보고 있는 달. 고른 날과 따로 둔다 — 지난 달을 넘겨봐도 고른 날은 그대로다
    var monthEpochDay by rememberSaveable { mutableLongStateOf(today.withDayOfMonth(1).toEpochDay()) }
    val selected = LocalDate.ofEpochDay(selectedEpochDay)

    Column(Modifier.fillMaxSize()) {
        // 헤더는 고정, 그 아래만 스크롤한다 (스토어와 같은 구조)
        AppHeader(onBranch = onBranch, onNotification = onNotification)
        Column(
            Modifier
                .weight(1f)
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
                .padding(bottom = MyFisSpacing.xxxl),
        ) {
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
        CongestionSection(
            congestion = congestionPlaceholder,
            modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
        )
        MileageShopSection(
            balance = mileageBalancePlaceholder,
            items = affordablePlaceholder(mileageBalancePlaceholder),
            onStore = onStore,
            modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
        )
        NewsSection(
            banners = newsBannerPlaceholder,
            notice = noticePlaceholder,
            onOpen = onNews,
            modifier = Modifier.padding(top = MyFisSpacing.sectionGap),
        )
        // TODO: 조건부 줄(회원권 D-7 · 미수령 교환권)이 마일리지 위에 붙는다 (SPEC H-01 ⑦).
        }
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
                // 오른쪽 뱃지와 세로 중심을 맞춘다 (패딩이 다르면 한쪽이 떠 보인다) —
                // 이제 **둘 다 `size.chip`** 이라 저절로 맞는다 (§5.2, 2026-08-27)
                .height(MyFisSize.chip)
                .clip(MyFisRadius.full)
                .tapWithHaptics(interaction, onToggle)
                .padding(horizontal = MyFisSpacing.sm),
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
                .height(MyFisSize.chip)
                .background(MyFisColor.Surface1, MyFisRadius.full)
                .padding(start = MyFisSpacing.sm, end = MyFisSpacing.md),
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

/**
 * 실시간 혼잡도 (DESIGN.md §6.15).
 *
 * 홈이 답해야 하는 질문은 **"지금 갈까?"** 다. 여기에 정면으로 답하는 카드다.
 * 숫자를 세우고, 색은 시맨틱(상태)으로 낸다 — 라임 예산과 무관하다 (§3.2).
 */
@Composable
private fun CongestionSection(congestion: BranchCongestion, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        Text("실시간 혼잡도", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.height(MyFisSpacing.md))
        CongestionCard(congestion)
    }
}

@Composable
private fun CongestionCard(congestion: BranchCongestion) {
    val level = congestion.level

    // TODO: 시간대별 혼잡도 상세(🔵)가 생기면 카드를 누를 수 있게 한다
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(MyFisRadius.md)
            .background(MyFisColor.Surface1)
            .padding(MyFisSpacing.cardPadding),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                congestion.branch,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextTertiary,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.weight(1f))
            Text(
                congestion.updatedLabel,
                style = MyFisTheme.type.caption,
                color = MyFisColor.TextTertiary,
            )
        }

        Spacer(Modifier.height(MyFisSpacing.xs))

        // **판단을 먼저 준다.** 숫자는 그 판단의 근거로 밑에 깐다
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(level.headline, style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
            Spacer(Modifier.width(MyFisSpacing.sm))
            // 상태는 **색과 글자 둘 다**로 낸다. 색만으로 구분하면 색각 이상에서 읽히지 않는다
            Text(
                level.label,
                style = MyFisTheme.type.label,
                color = level.color,
                modifier = Modifier
                    .background(level.color.copy(alpha = 0.14f), MyFisRadius.full)
                    .padding(horizontal = MyFisSpacing.sm, vertical = 2.dp),
            )
        }

        Text(
            "${congestion.people} / ${congestion.capacity}명",
            style = MyFisTheme.type.bodySm.copy(fontFeatureSettings = "tnum"),
            color = MyFisColor.TextTertiary,
        )

        Spacer(Modifier.height(MyFisSpacing.lg))

        HourlyChart(congestion = congestion, color = level.color)

        Spacer(Modifier.height(MyFisSpacing.md))

        Text(
            congestion.hint,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextSecondary,
        )
    }
}

/**
 * 오늘 시간대별 혼잡 막대.
 *
 * 지금 몇 명인지보다 **"언제 가면 한산한지"** 가 실제로 쓰는 정보다.
 * 지금 막대만 상태색이고 나머지는 흐린 회색 — 그래야 지금이 어디쯤인지 한눈에 뜬다.
 */
@Composable
private fun HourlyChart(congestion: BranchCongestion, color: Color) {
    val peak = (congestion.hourly.maxOrNull() ?: 1).coerceAtLeast(1)

    Column {
        Row(
            modifier = Modifier.fillMaxWidth().height(ChartHeight),
            verticalAlignment = Alignment.Bottom,
            horizontalArrangement = Arrangement.spacedBy(3.dp),
        ) {
            congestion.hourly.forEachIndexed { i, people ->
                Box(
                    Modifier
                        .weight(1f)
                        // 가장 한산한 시간도 막대가 보여야 한다 (0 이면 빈칸으로 읽힌다)
                        .fillMaxHeight((people.toFloat() / peak).coerceIn(0.12f, 1f))
                        .clip(MyFisRadius.full)
                        .background(if (i == congestion.nowIndex) color else MyFisColor.Surface3),
                )
            }
        }

        Spacer(Modifier.height(MyFisSpacing.sm))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(3.dp),
        ) {
            congestion.hourly.indices.forEach { i ->
                val hour = congestion.startHour + i
                Box(Modifier.weight(1f), contentAlignment = Alignment.Center) {
                    // 눈금은 3시간마다. 전부 적으면 숫자가 붙어 읽히지 않는다.
                    // `지금` 은 옆 칸까지 넘어오므로 양옆 눈금은 지운다 (겹쳐 찍힌다)
                    val tick = hour % 3 == 0 && kotlin.math.abs(i - congestion.nowIndex) > 1
                    if (tick || i == congestion.nowIndex) {
                        Text(
                            if (i == congestion.nowIndex) "지금" else hour.toString(),
                            style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                            color = if (i == congestion.nowIndex) {
                                MyFisColor.TextPrimary
                            } else {
                                MyFisColor.TextTertiary
                            },
                            maxLines = 1,
                            // `지금` 은 한 칸(≈14dp)보다 넓다. 칸을 넘겨서라도 온전히 보이게 한다
                            modifier = Modifier.wrapContentWidth(unbounded = true),
                        )
                    }
                }
            }
        }
    }
}

private val ChartHeight = 64.dp

/** 혼잡 단계. 신호등 순서라 설명 없이 읽힌다 */
private enum class CongestionLevel(val label: String, val headline: String, val color: Color) {
    LOW("한산", "지금 한산해요", MyFisColor.Success),
    MEDIUM("보통", "지금 딱 좋아요", MyFisColor.Warning),
    HIGH("혼잡", "지금 붐벼요", MyFisColor.Danger),
}

/** TODO(서버): 출입 스캔 기반 실시간 인원 API 가 붙으면 지운다 */
private data class BranchCongestion(
    val branch: String,
    val capacity: Int,
    val updatedLabel: String,
    /** 오늘 시간대별 인원. `startHour` 부터 1시간 간격 */
    val hourly: List<Int>,
    val startHour: Int,
    val nowHour: Int,
) {
    /** 영업 시간 밖이면 양 끝으로 붙인다 (새벽에 열어도 그래프가 깨지지 않게) */
    val nowIndex: Int = (nowHour - startHour).coerceIn(0, hourly.lastIndex)

    /** 지금 인원은 그래프와 **같은 값**을 쓴다. 둘이 다르면 어느 쪽도 못 믿는다 */
    val people: Int get() = hourly[nowIndex]

    val ratio: Float get() = (people.toFloat() / capacity).coerceIn(0f, 1f)

    val level: CongestionLevel
        get() = when {
            ratio < 0.4f -> CongestionLevel.LOW
            ratio < 0.75f -> CongestionLevel.MEDIUM
            else -> CongestionLevel.HIGH
        }

    /**
     * 앞으로 몇 시간 안에 가장 한산한 때 — 이 카드가 실제로 하는 일.
     *
     * **하루 전체에서 고르지 않는다.** 그러면 늘 문 닫기 직전을 찍는데, 그건 갈 수 있는 시간이 아니다.
     */
    val hint: String
        get() {
            val window = (nowIndex + 1)..minOf(nowIndex + HINT_HOURS, hourly.lastIndex - 1)
            val best = window.minByOrNull { hourly[it] } ?: return "오늘은 곧 문을 닫아요"
            if (hourly[best] >= people) return "지금이 한동안 제일 한산해요"
            return "${(startHour + best).toClockLabel()}쯤 가장 한산해요"
        }
}

/** 몇 시간 앞까지 추천할지. 이보다 멀면 "그때 가야지" 가 아니라 그냥 정보다 */
private const val HINT_HOURS = 6

/** `14` → `오후 2시` */
private fun Int.toClockLabel(): String = when {
    this < 12 -> "오전 ${this}시"
    this == 12 -> "낮 12시"
    else -> "오후 ${this - 12}시"
}

/** TODO(서버): 혼잡도 API 가 붙으면 지운다 */
private val congestionPlaceholder = BranchCongestion(
    branch = "강남점",
    capacity = 80,
    updatedLabel = "방금 업데이트",
    // 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23
    hourly = listOf(12, 26, 34, 24, 38, 30, 26, 20, 16, 18, 22, 34, 56, 68, 62, 44, 28, 14),
    startHour = 6,
    nowHour = LocalTime.now().hour,
)

/**
 * 마일리지로 바꾸기 (DESIGN.md §6.16).
 *
 * **추천의 기준은 취향이 아니라 잔액이다.** 구매 이력이 없어서 취향 추천은 광고로 읽히지만,
 * "지금 바꿀 수 있는 것" 은 계산만 하면 되니 처음부터 정확하다.
 * 원래 따로 두려던 마일리지 잔액 줄을 이 섹션이 흡수한다 — 홈이 한 칸 짧아진다.
 */
@Composable
private fun MileageShopSection(
    balance: Int,
    items: List<StoreItem>,
    onStore: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("마일리지로 바꾸기", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
            Spacer(Modifier.weight(1f))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Image(
                    painter = painterResource(R.drawable.ic_coin),
                    contentDescription = null, // 옆 숫자가 이름 역할을 한다
                    modifier = Modifier.size(20.dp),
                )
                MileageText(
                    balance,
                    style = MyFisTheme.type.titleSm,
                    modifier = Modifier.padding(start = MyFisSpacing.xs),
                )
            }
        }

        Spacer(Modifier.height(MyFisSpacing.md))

        Row(horizontalArrangement = Arrangement.spacedBy(MyFisSpacing.cardGap)) {
            items.forEach { item ->
                MileageItemCard(item = item, onClick = onStore, modifier = Modifier.weight(1f))
            }
        }
    }
}

/**
 * 홈용 상품 한 장. 스토어 그리드(§6.12)보다 **가볍게** 만든다 —
 * 카드 배경·찜·조회수 없이 이미지·이름·가격만. 홈은 훑는 자리지 고르는 자리가 아니다.
 */
@Composable
private fun MileageItemCard(item: StoreItem, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val interaction = remember { MutableInteractionSource() }

    Column(
        // 누름 축소는 **아이콘에만** 준다 (§6.7)
        modifier = modifier.tapWithHaptics(interaction, onClick),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2),
            contentAlignment = Alignment.Center,
        ) {
            // TODO(서버): 상품 이미지가 오면 교체한다. 지금은 자리만 잡는다.
            Icon(
                painter = painterResource(R.drawable.ic_tab_store),
                contentDescription = null,
                tint = MyFisColor.Surface3,
                modifier = Modifier.size(40.dp),
            )
        }
        Text(
            item.name,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        MileageText(
            item.price,
            style = MyFisTheme.type.titleSm,
            modifier = Modifier.padding(top = 2.dp),
        )
    }
}

/**
 * TODO(서버): "지금 바꿀 수 있는 상품" 은 서버가 골라준다. 붙으면 이 함수를 지운다.
 *
 * 잔액으로 바꿀 수 있고 품절이 아닌 것 중 인기순 3개. **부족한 상품은 넣지 않는다** —
 * 홈에서 "못 바꿔요" 를 보여줄 이유가 없다.
 */
private fun affordablePlaceholder(balance: Int): List<StoreItem> =
    storeItemPlaceholder
        .filter { !it.soldOut && it.price <= balance }
        .sortedByDescending { it.views }
        .take(3)

/**
 * 이벤트 · 새소식 (DESIGN.md §6.18).
 *
 * **홈의 맨 밑이 제 자리다.** 자주 보는 것도, 급한 것도 아니다 —
 * 그래도 없으면 이벤트를 알릴 데가 없다. 위에 두면 계기판을 가린다.
 */
@Composable
private fun NewsSection(
    banners: List<NewsBanner>,
    notice: String,
    onOpen: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = MyFisSpacing.screenHorizontal),
    ) {
        Text("이벤트 · 새소식", style = MyFisTheme.type.titleMd, color = MyFisColor.TextPrimary)
        Spacer(Modifier.height(MyFisSpacing.md))

        Column(
            Modifier
                .fillMaxWidth()
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface1)
                .padding(MyFisSpacing.cardPadding),
        ) {
            NewsCarousel(banners = banners, onOpen = onOpen)

            Box(
                Modifier
                    .padding(vertical = MyFisSpacing.md)
                    .fillMaxWidth()
                    .height(1.dp)
                    .background(MyFisColor.BorderSubtle),
            )

            NoticeRow(notice = notice, onClick = onOpen)
        }
    }
}

/**
 * 이벤트 배너.
 *
 * 스토어 배너(§6.12)와 달리 **자동으로 넘기지 않는다.** 홈 맨 밑에서 저 혼자 움직이면
 * 위쪽 계기판에서 시선을 뺏는다. 몇 장인지는 `01 / 03` 으로 알려 준다.
 */
@Composable
private fun NewsCarousel(banners: List<NewsBanner>, onOpen: () -> Unit) {
    val pager = rememberPagerState { banners.size }
    val interaction = remember { MutableInteractionSource() }

    HorizontalPager(
        state = pager,
        pageSpacing = MyFisSpacing.md,
        modifier = Modifier
            .fillMaxWidth()
            .height(NewsBannerHeight),
    ) { page ->
        val banner = banners[page]
        Box(
            Modifier
                .fillMaxSize()
                .clip(MyFisRadius.md)
                .background(MyFisColor.Surface2)
                .tapWithHaptics(interaction, onOpen)
                .padding(MyFisSpacing.lg),
        ) {
            Column {
                Text(
                    banner.title,
                    style = MyFisTheme.type.titleSm,
                    color = MyFisColor.TextPrimary,
                )
                Text(
                    banner.body,
                    style = MyFisTheme.type.bodySm,
                    color = MyFisColor.TextTertiary,
                    modifier = Modifier.padding(top = MyFisSpacing.xs),
                )
            }
            Text(
                // `1 / 3` 보다 자릿수가 고정돼 흔들리지 않는다
                "%02d / %02d".format(page + 1, banners.size),
                style = MyFisTheme.type.caption.copy(fontFeatureSettings = "tnum"),
                color = MyFisColor.TextTertiary,
                modifier = Modifier.align(Alignment.BottomStart),
            )
        }
    }
}

/** 공지 한 줄. 목록으로 가는 길이자, 이 섹션이 비어 보이지 않게 하는 최소한의 내용이다 */
@Composable
private fun NoticeRow(notice: String, onClick: () -> Unit) {
    val interaction = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(MyFisRadius.sm)
            .tapWithHaptics(interaction, onClick),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Text("공지", style = MyFisTheme.type.label, color = MyFisColor.TextSecondary)
        Box(
            Modifier
                .padding(horizontal = MyFisSpacing.sm)
                .size(width = 1.dp, height = 10.dp)
                .background(MyFisColor.BorderStrong),
        )
        Text(
            notice,
            style = MyFisTheme.type.bodySm,
            color = MyFisColor.TextPrimary,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f),
        )
        Icon(
            painter = painterResource(R.drawable.ic_chevron_down),
            contentDescription = null, // 옆 글자가 이름 역할을 한다
            tint = MyFisColor.TextTertiary,
            modifier = Modifier
                .size(18.dp)
                .graphicsLayer { rotationZ = -90f },
        )
    }
}

private val NewsBannerHeight = 108.dp

/** TODO(서버): 이벤트·공지 API 가 붙으면 지운다 (SPEC H-04) */
private data class NewsBanner(val id: Int, val title: String, val body: String)

/** TODO(서버): 이벤트 배너 API 가 붙으면 지운다 */
private val newsBannerPlaceholder = listOf(
    NewsBanner(1, "8월 신규 회원 2주 무료", "이달 등록하면 자동으로 붙어요"),
    NewsBanner(2, "친구 초대하고 1,000 P", "초대 코드로 등록하면 둘 다 받아요"),
    NewsBanner(3, "PT 10회 등록 시 1회 추가", "8월 31일까지"),
)

/** TODO(서버): 공지 API 가 붙으면 지운다 */
private const val noticePlaceholder = "8월 15일 광복절 정상 운영합니다"
