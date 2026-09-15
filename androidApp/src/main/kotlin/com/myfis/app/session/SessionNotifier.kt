package com.myfis.app.session

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.compose.ui.graphics.toArgb
import androidx.core.app.NotificationChannelCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.myfis.app.R
import com.myfis.app.ui.theme.MyFisColor

/**
 * 운동 세션 **진행 중 알림** — iOS 라이브 액티비티와 같은 자리 (DESIGN §6.37).
 *
 * ```
 * [웨이트] MyFIS · 운동 2 / 6 · 12:34      ← 머리 줄: 마디 + 시스템 크로노미터 (웜업이면 남은 시간을 거꾸로)
 * 스미스 머신 벤치 프레스                      ← 제목
 * 20kg × 12회                              ← 값 · 펼치면 아래에 `다음 · 인클라인 덤벨 프레스`
 * [일시정지]  [다음]
 * ```
 * - **Android 16+ 는 승격을 요청한다** (`setRequestPromotedOngoing`) — 상태 표시줄 칩 · 잠금화면 위쪽에 올라간다
 * - 시간은 **시각**(`setWhen`)으로 준다. 크로노미터는 멈출 수 없어서, 멈추면 끄고 멈춘 숫자를 글자로 적는다
 * - 소리 · 진동이 없다. 라임은 머리 줄 표식 색 하나다 (§3.2)
 */
internal object SessionNotifier {
    private const val CHANNEL = "workout_session"
    private const val NOTIFICATION_ID = 4001

    /** 완료 요약을 남기는 시간 — iOS 라이브 액티비티와 같은 15분 */
    private const val SUMMARY_LINGER_MS = 15 * 60 * 1000L

    @SuppressLint("MissingPermission") // 바로 위에서 권한을 확인한다
    fun post(context: Context, snapshot: SessionSnapshot) {
        if (!canPost(context)) return
        ensureChannel(context)

        val builder = NotificationCompat.Builder(context, CHANNEL)
            // FS 로고 — 상태 표시줄은 알파만 쓰므로 FS 실루엣으로 찍힌다 (iOS 잠금화면 표식과 맞춘다)
            .setSmallIcon(R.drawable.ic_logo)
            .setColor(MyFisColor.Accent.toArgb())
            .setContentIntent(openApp(context))
            .setSilent(true)
            .setOnlyAlertOnce(true)
            .setCategory(NotificationCompat.CATEGORY_STOPWATCH)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        if (snapshot.finished) {
            builder
                .setContentTitle("오늘 운동을 마쳤어요")
                .setContentText("총 ${mmss(snapshot.elapsedSeconds)}")
                .setOngoing(false)
                .setAutoCancel(true)
                .setShowWhen(false)
                .setTimeoutAfter(SUMMARY_LINGER_MS)
        } else {
            val value = valueLine(snapshot)
            val next = nextLine(snapshot)
            builder
                .setOngoing(true)
                .setRequestPromotedOngoing(true)
                .setSubText(snapshot.stageLabel)
                .setContentTitle(snapshot.title)
                .setContentText(value ?: next)
                // ⚠️ 흐르는 웜업은 값 줄이 없어 본문이 곧 `다음` 줄이다 — 펼친 글에 한 번 더 붙이면 두 줄로 겹친다
                .setStyle(NotificationCompat.BigTextStyle().bigText(listOfNotNull(value, next).joinToString("\n")))
                .addAction(
                    action(
                        context,
                        SessionActionReceiver.ACTION_TOGGLE,
                        if (snapshot.isPlaying) R.drawable.ic_session_pause else R.drawable.ic_session_play,
                        if (snapshot.isPlaying) "일시정지" else "이어서 하기",
                    ),
                )
                .addAction(action(context, SessionActionReceiver.ACTION_NEXT, R.drawable.ic_session_next, "다음"))

            val warmupUntil = snapshot.warmupUntil
            if (snapshot.isPlaying) {
                builder.setShowWhen(true).setUsesChronometer(true)
                if (warmupUntil != null) {
                    builder.setWhen(warmupUntil).setChronometerCountDown(true)
                } else {
                    builder.setWhen(snapshot.elapsedFrom).setChronometerCountDown(false)
                }
            } else {
                builder.setShowWhen(false).setUsesChronometer(false).setShortCriticalText("일시정지")
            }
        }

        NotificationManagerCompat.from(context).notify(NOTIFICATION_ID, builder.build())
    }

    fun cancel(context: Context) {
        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
    }

    /**
     * 앱이 뜰 때 — 지난번에 앱이 죽으며 남긴 **진행 중** 알림을 치운다 (세션은 메모리라 이어 받을 수 없다).
     * 끝난 요약은 스스로 사라지므로 둔다
     */
    fun cancelOrphan(context: Context) {
        if (WorkoutSessionStore.isRunning) return
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        val orphan = manager.activeNotifications.any {
            it.id == NOTIFICATION_ID && it.notification.flags and Notification.FLAG_ONGOING_EVENT != 0
        }
        if (orphan) cancel(context)
    }

    // ── 글자 ──────────────────────────────────────────────

    /**
     * 1순위 줄 — 운동은 처방, 멈췄으면 멈춘 숫자.
     * 흐르는 웜업은 `null` 이다 — 숫자는 머리 줄 크로노미터가 맡는다
     */
    private fun valueLine(snapshot: SessionSnapshot): String? {
        val paused = if (snapshot.isPlaying) null else {
            val seconds = if (snapshot.warmupUntil != null) snapshot.remainSeconds else snapshot.elapsedSeconds
            "일시정지 ${mmss(seconds)}"
        }
        return listOfNotNull(snapshot.load, paused).joinToString(" · ").ifEmpty { null }
    }

    private fun nextLine(snapshot: SessionSnapshot): String =
        snapshot.nextTitle?.let { "다음 · $it" } ?: "마지막이에요"

    private fun mmss(seconds: Int): String = "%02d:%02d".format(seconds / 60, seconds % 60)

    // ── 붙이는 것 ─────────────────────────────────────────

    private fun canPost(context: Context): Boolean =
        Build.VERSION.SDK_INT < 33 ||
            ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED

    private fun ensureChannel(context: Context) {
        val manager = NotificationManagerCompat.from(context)
        if (manager.getNotificationChannelCompat(CHANNEL) != null) return
        // 승격 알림은 중요도가 MIN 이면 안 된다 — 기본으로 두고 소리 · 진동을 끈다
        manager.createNotificationChannel(
            NotificationChannelCompat.Builder(CHANNEL, NotificationManagerCompat.IMPORTANCE_DEFAULT)
                .setName("운동 세션")
                .setDescription("운동 중 경과 시간과 다음 동작을 알림창 · 잠금화면에 띄워요")
                .setSound(null, null)
                .setVibrationEnabled(false)
                .setShowBadge(false)
                .build(),
        )
    }

    /** 알림을 누르면 **떠 있던 앱으로** 돌아간다 — 런처와 같은 인텐트라 새 화면을 쌓지 않는다 */
    private fun openApp(context: Context): PendingIntent? {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return null
        launch.addFlags(Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        return PendingIntent.getActivity(
            context, 0, launch, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }

    private fun action(context: Context, name: String, icon: Int, title: String): NotificationCompat.Action {
        val intent = Intent(context, SessionActionReceiver::class.java).setAction(name)
        val pending = PendingIntent.getBroadcast(
            context, name.hashCode(), intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        return NotificationCompat.Action.Builder(icon, title, pending).build()
    }
}
