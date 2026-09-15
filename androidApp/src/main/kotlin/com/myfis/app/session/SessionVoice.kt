package com.myfis.app.session

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.util.Locale

/**
 * 운동 세션 **음성 가이드** — 시스템 음성 합성(`TextToSpeech`)으로 읽는다. iOS `SessionVoice` 와 같은 자리 (DESIGN §6.37).
 *
 * 🟢 (2026-09-15, 사용자 지정 — *안내 음성 · 무음 모드여도 말한다*). 읽을 말은 `shared` 의 `SessionVoiceScript` 한 벌이다.
 * 언제 말할지는 [WorkoutSessionStore] 가 정한다
 * - **무음 모드를 따르지 않는다** — 길 안내 용도(`USAGE_ASSISTANCE_NAVIGATION_GUIDANCE`)라 벨소리 모드와 상관없이 난다
 * - 말하는 동안 **다른 앱 음악을 줄였다가**(`AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK`) 끝나면 돌려놓는다
 * - 새 말은 **하던 말을 끊는다** (`QUEUE_FLUSH`) — `다음` 을 연달아 누르면 마지막 단계만 읽는다
 * - 엔진은 뜨는 데 시간이 걸린다 (에뮬레이터 약 3초) — 그 전에 온 말은 **마지막 것만** 들고 있다가 읽는다
 * - ⚠️ **엔진은 따로 도는 앱이라 죽을 수 있다** — 에뮬레이터에서 70초 만에 연결이 끊겨 말하기가 `DeadObjectException` 으로 실패했다.
 *   실패하면 **다시 붙이고 그 말은 붙은 뒤 읽는다.** 붙자마자 또 실패하면 그 말은 버린다 (무한히 다시 붙이지 않게)
 * - 한국어 음성이 없는 폰이면 조용히 넘어간다 (로그만)
 * - ⚠️ Android 11+ 는 음성 엔진을 찾으려면 매니페스트에 `TTS_SERVICE` 조회를 선언해야 한다
 */
class SessionVoice(context: Context) : TextToSpeech.OnInitListener {
    private val app = context.applicationContext
    private val audio = app.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_ASSISTANCE_NAVIGATION_GUIDANCE)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()
    private val focus: AudioFocusRequest? =
        if (Build.VERSION.SDK_INT >= 26) {
            AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(attributes)
                .build()
        } else {
            null
        }

    private var ready = false
    private var pending: String? = null
    /** 마지막으로 건 말 — 끊긴 옛 말의 `끝났다` 소식에 음악을 돌려놓지 않게 */
    @Volatile private var latest: String? = null
    private var count = 0
    /** 다시 붙인 뒤 아직 한 마디도 못 했다 — 이때 또 실패하면 다시 붙이지 않는다 */
    private var restarted = false

    private var tts = TextToSpeech(app, this)

    override fun onInit(status: Int) {
        if (status != TextToSpeech.SUCCESS) {
            Log.w(TAG, "음성 엔진 시작 실패 — $status")
            return
        }
        val language = tts.setLanguage(Locale.KOREAN)
        Log.d(TAG, "음성 엔진 준비 — 한국어 설정 결과 $language")
        if (language == TextToSpeech.LANG_MISSING_DATA || language == TextToSpeech.LANG_NOT_SUPPORTED) {
            Log.w(TAG, "한국어 음성이 없다 — 말하지 않는다")
            return
        }
        tts.setAudioAttributes(attributes)
        tts.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) = Unit
            override fun onDone(utteranceId: String?) = settle(utteranceId)
            override fun onStop(utteranceId: String?, interrupted: Boolean) = settle(utteranceId)

            @Deprecated("Deprecated in Java")
            override fun onError(utteranceId: String?) = settle(utteranceId)
        })
        ready = true
        pending?.let {
            pending = null
            say(it)
        }
    }

    fun say(text: String) {
        Log.d(TAG, "음성 — $text${if (ready) "" else " (엔진 준비 전, 들고 있음)"}")
        if (!ready) {
            pending = text
            return
        }
        val id = "session-${++count}"
        latest = id
        requestFocus()
        if (tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, id) == TextToSpeech.SUCCESS) {
            restarted = false
            return
        }
        abandonFocus()
        if (restarted) {
            Log.w(TAG, "다시 붙인 뒤에도 말하기 실패 — 이 말은 버린다")
            return
        }
        Log.w(TAG, "말하기 실패 — 엔진을 다시 붙인다")
        restarted = true
        ready = false
        pending = text
        tts.shutdown()
        tts = TextToSpeech(app, this)
    }

    fun stop() {
        pending = null
        latest = null
        if (ready) tts.stop()
        abandonFocus()
    }

    /** 말을 다 했거나 끊겼을 때 — **마지막 말이 끝났을 때만** 줄여 둔 음악을 돌려놓는다 */
    private fun settle(utteranceId: String?) {
        if (utteranceId == latest) abandonFocus()
    }

    private fun requestFocus() {
        if (focus != null) {
            audio.requestAudioFocus(focus)
        } else {
            @Suppress("DEPRECATION")
            audio.requestAudioFocus(null, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
        }
    }

    private fun abandonFocus() {
        if (focus != null) {
            audio.abandonAudioFocusRequest(focus)
        } else {
            @Suppress("DEPRECATION")
            audio.abandonAudioFocus(null)
        }
    }

    private companion object {
        const val TAG = "SessionVoice"
    }
}
