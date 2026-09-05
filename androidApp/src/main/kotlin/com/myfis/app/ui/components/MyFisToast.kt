package com.myfis.app.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSize
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * 토스트 — **"했다"를 알리는 자리** (DESIGN.md §6.35).
 *
 * **위에서 내려온다** 🟢 (2026-09-06, 사용자 지정). 셸 맨 위에 얹히므로 잎 화면 위에도 뜬다.
 *
 * ⚠️ **쓰지 않는 자리가 정해져 있다** (SPEC) —
 * 마일리지 **적립**은 화면 안에서 알리고, **에러**도 토스트로 끝내지 않는다.
 * 토스트는 *되돌아볼 일 없는 짧은 완료*만 맡는다 — 만들었다 · 담았다 · 지웠다.
 *
 * **라임을 쓰지 않는다** (§3.2) — 2초 뜨는 것이 화면당 두 곳뿐인 액센트 예산을 먹으면 안 된다.
 * **Material `Snackbar` 를 쓰지 않는다** — 바닥에서 올라오고 표면·모서리가 우리 것과 다르다 (§10)
 */
class ToastState {
    var text by mutableStateOf<String?>(null)
        private set

    /** 늦게 도착한 예약이 새 토스트를 지우면 안 된다 */
    var token by mutableIntStateOf(0)
        private set

    fun show(message: String) {
        text = message
        token += 1
    }

    fun hide(forToken: Int) {
        if (token == forToken) text = null
    }
}

/** 셸 맨 위에 얹는 자리. 잎보다도 위다 — 잎에서 한 일도 알려야 한다. */
@Composable
fun ToastLayer(state: ToastState, modifier: Modifier = Modifier) {
    val message = state.text
    val token = state.token

    LaunchedEffect(token) {
        if (message != null) {
            kotlinx.coroutines.delay(ToastHoldMillis)
            state.hide(token)
        }
    }

    Box(
        modifier
            .fillMaxSize()
            .statusBarsPadding(),
        contentAlignment = Alignment.TopCenter,
    ) {
        AnimatedVisibility(
            visible = message != null,
            // 위에서 내려온다 — 들어온 곳으로 되돌아 나간다
            enter = slideInVertically(tween(200)) { -it } + fadeIn(tween(200)),
            exit = slideOutVertically(tween(200)) { -it } + fadeOut(tween(200)),
            modifier = Modifier
                // **헤더 밑에 뜬다** — 헤더 줄에 겹치면 헤더의 일부처럼 읽힌다
                .padding(top = MyFisSize.header + MyFisSpacing.sm)
                .wrapContentHeight(),
        ) {
            Text(
                message.orEmpty(),
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier
                    // 위계는 **표면 밝기**로 낸다 (§5.4) — 그림자를 쓰지 않는다
                    .background(MyFisColor.Surface3, MyFisRadius.full)
                    .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.full)
                    .height(MyFisSize.buttonSecondary)
                    .wrapContentHeight()
                    .padding(horizontal = MyFisSpacing.lg),
            )
        }
    }
}

/** 토스트가 **머무는 시간** (§6.35) — 들어오고 나가는 `base`(200) 와 별개다 */
const val ToastHoldMillis = 2000L
