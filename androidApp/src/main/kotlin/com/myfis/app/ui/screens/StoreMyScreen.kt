package com.myfis.app.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.myfis.app.ui.shell.DetailHeader
import com.myfis.app.ui.shell.PlaceholderScreen
import com.myfis.app.ui.theme.MyFisColor

/**
 * SPEC.md S-08 스토어 마이.
 *
 * **마이 탭(Y-01)과 다른 화면이다.** 여기는 스토어 안에서의 나 —
 * 교환권(S-04) · 교환 내역(S-05) · 장바구니(S-06) 처럼 **교환에 관한 것만** 모인다.
 * 프로필·기록·설정은 마이 탭이 맡는다.
 *
 * 스토어 헤더에서 **오른쪽에서 왼쪽으로 밀려 들어온다** (잎 화면, DESIGN.md §7.1).
 */
@Composable
fun StoreMyScreen(onBack: () -> Unit) {
    Column(
        Modifier
            .fillMaxSize()
            .background(MyFisColor.BgBase)
            .statusBarsPadding(),
    ) {
        DetailHeader("스토어 마이", onBack)
        // TODO: 보유 마일리지 · 교환권 · 교환 내역 · 장바구니가 붙으면 교체한다 (SPEC S-08).
        PlaceholderScreen("S-08", "스토어 마이", "교환권 · 교환 내역 · 장바구니")
    }
}
