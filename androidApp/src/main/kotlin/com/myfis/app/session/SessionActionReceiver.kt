package com.myfis.app.session

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * 진행 중 알림의 `일시정지` · `다음` — iOS `LiveActivityIntent` 와 같은 자리.
 *
 * 앱 안에서만 받는다 (`exported = false`). 메인 스레드에서 불리므로 저장소를 바로 만진다
 */
class SessionActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_TOGGLE -> WorkoutSessionStore.toggle()
            ACTION_NEXT -> WorkoutSessionStore.next()
        }
        // 앱이 죽었다 이 버튼으로 깨어났으면 저장소가 비어 있다 — 버튼이 할 일이 없으니 알림을 걷는다
        if (!WorkoutSessionStore.isRunning) SessionNotifier.cancel(context)
    }

    companion object {
        const val ACTION_TOGGLE = "com.myfis.app.session.TOGGLE"
        const val ACTION_NEXT = "com.myfis.app.session.NEXT"
    }
}
