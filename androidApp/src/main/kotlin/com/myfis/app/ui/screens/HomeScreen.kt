package com.myfis.app.ui.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.myfis.app.ui.components.WeekCalendar
import com.myfis.app.ui.components.weekOf
import com.myfis.app.ui.shell.PlaceholderScreen
import com.myfis.app.ui.theme.MyFisSpacing
import java.time.LocalDate

/**
 * SPEC.md H-01 홈.
 *
 * 헤더 바로 밑에 **이번 주 캘린더**가 있고, 그 아래가 고른 날의 내용이다.
 * 아직 카드가 없어 자리값만 둔다.
 */
@Composable
fun HomeScreen() {
    val today = remember { LocalDate.now() }
    val week = remember(today) { weekOf(today) }

    // LocalDate 는 Saveable 이 아니라 epochDay 로 들고 있는다.
    var selectedEpochDay by rememberSaveable { mutableLongStateOf(today.toEpochDay()) }
    val selected = LocalDate.ofEpochDay(selectedEpochDay)

    Column(Modifier.fillMaxSize()) {
        WeekCalendar(
            week = week,
            selected = selected,
            onSelect = { selectedEpochDay = it.toEpochDay() },
            modifier = Modifier.padding(top = MyFisSpacing.sm),
        )
        // TODO: 회원권 카드 · 오늘 할 운동 · 마일리지가 붙으면 교체한다 (SPEC H-01).
        PlaceholderScreen("H-01", "홈", "회원권 상태 · 오늘 할 운동 · 마일리지")
    }
}
