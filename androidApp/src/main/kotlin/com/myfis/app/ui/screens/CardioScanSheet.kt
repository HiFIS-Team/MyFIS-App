package com.myfis.app.ui.screens

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.nfc.NfcAdapter
import android.provider.Settings
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.BottomSheetDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor
import com.myfis.app.ui.theme.MyFisRadius
import com.myfis.app.ui.theme.MyFisSecondaryButton
import com.myfis.app.ui.theme.MyFisSpacing
import com.myfis.app.ui.theme.MyFisTheme

/**
 * SPEC.md C-02 기기 NFC 스캔 — **안드로이드 몫의 시트**.
 *
 * ⚠️ **안드로이드에는 시스템 NFC 화면이 없다.** 폰이 태그를 조용히 읽을 뿐이라
 * 우리가 이 시트를 안 그리면 **"폰을 대라"는 신호가 화면에 하나도 안 뜬다.**
 * iOS 는 반대다 — `CoreNFC` 를 부르면 **시스템이 자기 시트를 띄우고 앱은 못 만든다.**
 * 그래서 이 화면은 **안드로이드에만 있다** (SPEC C-02).
 *
 * **실패해도 이 시트를 벗어나지 않는다** (SPEC) — 사유만 갈아 끼우고 다시 댈 수 있게 둔다.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardioScanSheet(onDismiss: () -> Unit) {
    val context = LocalContext.current
    val state = nfcState(context)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(),
        containerColor = MyFisColor.Surface1,
        contentColor = MyFisColor.TextPrimary,
        shape = MyFisRadius.sheet,
        scrimColor = MyFisColor.BgBase.copy(alpha = 0.72f),
        dragHandle = { BottomSheetDefaults.DragHandle(color = MyFisColor.BorderStrong) },
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = MyFisSpacing.screenHorizontal)
                .padding(top = MyFisSpacing.lg, bottom = MyFisSpacing.xxxl),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            TagTarget()

            Text(
                state.title,
                style = MyFisTheme.type.titleMd,
                color = MyFisColor.TextPrimary,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = MyFisSpacing.xxl),
            )
            Text(
                state.detail,
                style = MyFisTheme.type.bodySm,
                color = MyFisColor.TextSecondary,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = MyFisSpacing.sm),
            )

            if (state == ScanState.OFF) {
                MyFisSecondaryButton(
                    "NFC 켜기",
                    onClick = { context.startActivity(Intent(Settings.ACTION_NFC_SETTINGS)) },
                    modifier = Modifier.padding(top = MyFisSpacing.xxl),
                )
            } else {
                MyFisSecondaryButton(
                    "취소",
                    onClick = onDismiss,
                    modifier = Modifier.padding(top = MyFisSpacing.xxl),
                )
            }
        }
    }
}

/**
 * 태그를 대는 자리 — **고리 두 겹 안에 기기 그림**.
 *
 * 전파가 퍼지는 모양을 그리지 않는다. 태그는 **한 점에 대는 것**이라
 * 퍼지는 그림은 오히려 "어디든 대면 된다"로 읽힌다.
 */
@Composable
private fun TagTarget() {
    Box(contentAlignment = Alignment.Center) {
        Box(
            Modifier
                .size(140.dp)
                .border(1.dp, MyFisColor.BorderSubtle, MyFisRadius.full),
        )
        Box(
            Modifier
                .size(104.dp)
                .border(1.dp, MyFisColor.BorderStrong, MyFisRadius.full),
        )
        Icon(
            painter = painterResource(R.drawable.ic_tab_cardio),
            contentDescription = null,
            tint = MyFisColor.Accent,
            modifier = Modifier.size(44.dp),
        )
    }
}

/**
 * 시트가 지금 무슨 말을 할지.
 *
 * 나머지 사유(등록 안 된 태그 · 사용 중 · 기기 오프라인)는 **서버가 답해야 알 수 있다** —
 * 🔵 세션 생성이 붙으면 여기에 더한다 (SPEC C-02).
 */
private enum class ScanState(val title: String, val detail: String) {
    READY("기기에 폰을 대주세요", "손잡이나 계기판의 태그를 찾으세요"),
    OFF("NFC 가 꺼져 있어요", "설정에서 켜면 바로 시작할 수 있어요"),
    UNSUPPORTED("이 폰은 NFC 를 지원하지 않아요", "데스크에 말씀해 주세요"),
}

private fun nfcState(context: Context): ScanState {
    debugState(context)?.let { return it }

    val adapter = NfcAdapter.getDefaultAdapter(context)
    return when {
        adapter == null -> ScanState.UNSUPPORTED
        !adapter.isEnabled -> ScanState.OFF
        else -> ScanState.READY
    }
}

/**
 * 확인용 훅 — **디버그 빌드에서만 동작한다.** iOS `MyFisDebug` 와 같은 취지로 **상주시킨다.**
 *
 * 에뮬레이터에는 NFC 가 없어서 **주 상태(`READY`)를 볼 방법이 이것뿐이다.**
 *
 * ```
 * adb shell settings put global myfis_nfc ready   대기 화면
 * adb shell settings put global myfis_nfc off     NFC 꺼짐
 * adb shell settings delete global myfis_nfc      실제 상태로
 * ```
 */
private fun debugState(context: Context): ScanState? {
    // `BuildConfig` 를 켜려고 빌드 파일을 건드리지 않는다 — 플래그로 바로 알 수 있다
    if (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE == 0) return null
    return when (Settings.Global.getString(context.contentResolver, "myfis_nfc")) {
        "ready" -> ScanState.READY
        "off" -> ScanState.OFF
        "unsupported" -> ScanState.UNSUPPORTED
        else -> null
    }
}
