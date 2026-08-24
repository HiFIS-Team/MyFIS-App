package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.components.WeekCalendar
import com.myfis.app.ui.components.weekOf
import com.myfis.app.ui.shell.AppHeader
import com.myfis.app.ui.shell.PlaceholderScreen
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme
import com.myfis.app.ui.theme.pressScale
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
) {
    val today = remember { LocalDate.now() }
    val week = remember(today) { weekOf(today) }

    // LocalDate 는 Saveable 이 아니라 epochDay 로 들고 있는다.
    var selectedEpochDay by rememberSaveable { mutableLongStateOf(today.toEpochDay()) }
    val selected = LocalDate.ofEpochDay(selectedEpochDay)

    Column(Modifier.fillMaxSize()) {
        AppHeader(onNotification = onNotification)
        WeekCalendar(
            week = week,
            selected = selected,
            onSelect = { selectedEpochDay = it.toEpochDay() },
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        ShortcutRow(
            onDiet = onDiet,
            onCardio = onCardio,
            modifier = Modifier.padding(top = MyFisSpacing.lg),
        )
        // TODO: 회원권 카드 · 오늘 할 운동 · 마일리지가 붙으면 교체한다 (SPEC H-01).
        PlaceholderScreen("H-01", "홈", "회원권 상태 · 오늘 할 운동 · 마일리지")
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
    val press by interaction.pressScale()

    Row(
        modifier = modifier
            .graphicsLayer {
                scaleX = press
                scaleY = press
            }
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
