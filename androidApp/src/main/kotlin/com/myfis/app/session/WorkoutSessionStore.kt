package com.myfis.app.session

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.myfis.app.shared.workout.SessionClock
import com.myfis.app.shared.workout.SessionVoiceScript
import com.myfis.app.ui.screens.SessionStage
import com.myfis.app.ui.screens.SessionStep
import com.myfis.app.ui.screens.loadAndReps
import com.myfis.app.ui.screens.sessionStageLabel

/**
 * 운동 세션(W-04)의 **화면 밖 저장소** — iOS `WorkoutSessionStore` 와 같은 자리 (DESIGN §6.37).
 *
 * 세션 화면 · 진행 중 알림 · 알림 버튼 셋이 **같은 시계**를 본다.
 * 알림 버튼은 [SessionActionReceiver] 로 들어오므로, 시계가 화면 `remember` 안에 있으면 닿을 수 없다.
 *
 * - 알림은 **바뀔 때만** 다시 올린다 — 단계 · 재생 여부 · 끝남. 시간은 시스템 크로노미터가 흘린다
 * - ⚠️ **포그라운드 서비스를 쓰지 않는다** 🔵 — 앱이 뒤에서 시스템에 정리되면 알림 버튼이 할 일이 없다.
 *   그때는 받는 쪽이 알림을 걷는다 ([SessionActionReceiver])
 */
object WorkoutSessionStore {
    /** 마지막 세션의 시계. **닫힌 뒤에도 남긴다** — 화면이 밀려 나가는 동안 마지막 모습을 그려야 한다 */
    var clock by mutableStateOf<SessionClock?>(null)
        private set

    /** 세션이 열려 있다 (화면이 떠 있다) */
    var isRunning by mutableStateOf(false)
        private set

    /** 음성 가이드 켜짐 — 세션 화면 칩이 바꾼다. 세션을 열 때마다 켜진 채로 시작한다 */
    var voiceOn by mutableStateOf(true)
        private set

    private var steps: List<SessionStep> = emptyList()
    private var appContext: Context? = null

    /** 음성 가이드 (§6.37) — 말은 `SessionVoiceScript`, 언제 말할지는 여기([speak])가 정한다. 앱이 살아 있는 동안 하나를 쓴다 */
    private var voice: SessionVoice? = null
    /** 이 단계에서 이미 센 숫자 (단계 · 남은 초) — 멈췄다 이어도 같은 숫자를 두 번 세지 않는다 */
    private var countedDown: Pair<Int, Int>? = null

    /** 새 세션을 연다 */
    fun start(context: Context, steps: List<SessionStep>) {
        val app = context.applicationContext
        appContext = app
        this.steps = steps
        val now = System.currentTimeMillis()
        val started = SessionClock.start(steps.map { it.seconds ?: 0 }, now)
        clock = started
        isRunning = true
        voiceOn = true
        countedDown = null
        val voice = voice ?: SessionVoice(app).also { voice = it }
        voice.say(entering(0))
        SessionNotifier.post(app, snapshot(started, now))
    }

    fun toggleVoice() {
        voiceOn = !voiceOn
        if (!voiceOn) voice?.stop()
    }

    /** 틱마다 — 시간이 다 된 웜업을 넘긴다 */
    fun tick() = update { clock, now -> clock.catchUp(now) }

    fun toggle() = update { clock, now -> clock.toggle(now) }

    fun next() = update { clock, now -> clock.next(now) }

    fun previous() = update { clock, now -> clock.previous(now) }

    /** 알림 권한을 방금 받았을 때 — 지금 모습으로 한 번 올린다 */
    fun refreshNotification() {
        val app = appContext ?: return
        val current = clock ?: return
        if (isRunning) SessionNotifier.post(app, snapshot(current, System.currentTimeMillis()))
    }

    /** 화면이 닫힐 때. **끝나서 닫히면** 요약은 이미 남겼으니 두고, 중간에 나가면 바로 걷는다 */
    fun close() {
        if (!isRunning) return
        isRunning = false
        // 끝나서 닫히면 `오늘 운동을 마쳤어요` 를 끝까지 읽게 둔다
        if (clock?.finished != true) voice?.stop()
        val app = appContext ?: return
        if (clock?.finished != true) SessionNotifier.cancel(app)
    }

    /** 시계가 바뀔 때마다 — **끝남 · 단계 바뀜 · 웜업 끝 3초** 에만 말한다. 멈춤 · 이어서는 말하지 않는다 */
    private fun speak(old: SessionClock, new: SessionClock, now: Long) {
        if (!voiceOn) return
        val voice = voice ?: return
        when {
            new.finished && !old.finished -> voice.say(SessionVoiceScript.FINISHED)
            new.index != old.index -> {
                countedDown = null
                voice.say(entering(new.index))
            }
            new.isTimed && new.isPlaying -> {
                val mark = new.index to new.remainSeconds(now)
                val word = SessionVoiceScript.countdown(mark.second)
                if (mark != countedDown && word != null) {
                    countedDown = mark
                    voice.say(word)
                }
            }
        }
    }

    private fun entering(index: Int): String {
        val step = steps[index]
        return SessionVoiceScript.entering(
            warmup = step.stage == SessionStage.WARMUP,
            within = steps.take(index + 1).count { it.stage == step.stage },
            total = steps.count { it.stage == step.stage },
            title = step.title,
            seconds = step.seconds ?: 0,
            sets = step.exercise?.sets ?: 0,
            load = step.exercise?.load,
            reps = step.exercise?.reps ?: 0,
        )
    }

    private inline fun update(change: (SessionClock, Long) -> SessionClock) {
        if (!isRunning) return
        val old = clock ?: return
        val now = System.currentTimeMillis()
        val updated = change(old, now)
        clock = updated
        speak(old, updated, now)
        val changed = updated.finished != old.finished ||
            updated.index != old.index ||
            updated.isPlaying != old.isPlaying
        val app = appContext
        if (changed && app != null) SessionNotifier.post(app, snapshot(updated, now))
    }

    /** 시계에서 **그릴 값만** 뽑는다. 시간은 시각으로 — 시스템 크로노미터가 흘린다 */
    private fun snapshot(clock: SessionClock, now: Long): SessionSnapshot {
        val step = steps[clock.index]
        // 시계가 선 시각 — 멈춰 있으면 멈춘 시각, 아니면 지금
        val reference = if (clock.isPlaying) now else clock.pausedAt
        return SessionSnapshot(
            stageLabel = sessionStageLabel(steps, clock.index),
            title = step.title,
            load = step.exercise?.loadAndReps,
            nextTitle = steps.getOrNull(clock.index + 1)?.title,
            elapsedFrom = reference - clock.elapsed(now),
            warmupUntil = if (clock.isTimed) reference + clock.remainMillis(now) else null,
            elapsedSeconds = clock.elapsedSeconds(now),
            remainSeconds = clock.remainSeconds(now),
            isPlaying = clock.isPlaying,
            finished = clock.finished,
        )
    }
}

/** 알림에 그릴 값 — iOS `WorkoutActivityAttributes.ContentState` 와 같은 자리 */
data class SessionSnapshot(
    /** `웜업 스트레칭 1 / 5` · `운동 2 / 6` */
    val stageLabel: String,
    val title: String,
    /** 운동이면 `20kg × 12회`, 웜업이면 `null` */
    val load: String?,
    /** 다음 단계 이름. 마지막이면 `null` */
    val nextTitle: String?,
    /** 총 경과가 0 이던 시각 (epoch ms) */
    val elapsedFrom: Long,
    /** 웜업이 끝나는 시각 (epoch ms). 운동이면 `null` */
    val warmupUntil: Long?,
    /** 멈췄을 때 · 끝났을 때 글자로 적는 숫자 */
    val elapsedSeconds: Int,
    val remainSeconds: Int,
    val isPlaying: Boolean,
    val finished: Boolean,
)
