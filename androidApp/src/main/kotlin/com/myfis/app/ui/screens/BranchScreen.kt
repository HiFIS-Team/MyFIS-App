package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.theme.MyFisColor

/**
 * 홈 헤더의 **핀으로 들어오는 잎 화면** — 지금은 빈 껍데기다.
 *
 * 길만 먼저 뚫어 뒀다 (셸을 덮고 오른쪽에서 밀려 들어온다, DESIGN.md §7.1).
 * 🔵 무엇을 담을지는 미정이다 — SPEC M-01 지점 선택이 후보지만 확정 아니다.
 *
 * ⚠️ 잎 화면은 셸 밖이라 **바탕색과 상태바 여백을 스스로 넣는다.**
 * 바탕이 없으면 밀려 들어오는 동안 뒤 화면이 비쳐 겹쳐 보이고, 여백이 없으면 헤더가 시계에 겹친다.
 */
@Composable
fun BranchScreen(onBack: () -> Unit = {}) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader(title = null, onBack = onBack)
    }
}
