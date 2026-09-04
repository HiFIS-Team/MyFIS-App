package com.myfis.app.ui.shell

import androidx.compose.runtime.compositionLocalOf
import androidx.compose.ui.unit.dp

/**
 * **떠 있는 탭 바가 덮는 높이** (DESIGN.md §6.7, 2026-09-04).
 *
 * 웨이트 세트에서 바는 콘텐츠 **위에 얹힌다** — 그래야 바 아래 틈과 좌우 여백으로
 * 뒤가 비친다 (레퍼런스 토스). 그 대신 화면이 **가려지는 만큼 스스로 비워 둬야** 한다.
 *
 * - 붙어 있는 기본 세트에서는 `0` 이다. 그때는 셸이 바 높이만큼 콘텐츠를 줄여 준다
 * - iOS 는 이 값이 필요 없다 — 네이티브 `TabView` 가 스크롤에 안전 영역을 알아서 넣는다
 */
val LocalTabBarInset = compositionLocalOf { 0.dp }
