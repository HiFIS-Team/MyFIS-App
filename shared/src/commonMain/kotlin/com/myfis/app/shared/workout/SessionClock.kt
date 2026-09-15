package com.myfis.app.shared.workout

/**
 * 운동 세션(W-04)의 시계 — **시각으로 계산한다** (DESIGN §6.37 · SPEC W-04).
 *
 * 전에는 화면이 1초마다 숫자를 1씩 더했다. 폰을 잠그거나 앱을 내리면 그 사이 틱이 오지 않아
 * **돌아왔을 때 경과 시간이 실제보다 덜 흘러 있었다.** 잠금화면(라이브 액티비티 · 진행 중 알림)은
 * 시스템이 시각으로 흘리므로, 앱도 시각으로 세야 두 숫자가 같다.
 *
 * - 값은 바뀌지 않는다 — 조작은 전부 **새 시계를 돌려준다.** 화면은 받아서 갈아 끼우기만 한다
 * - 시각은 밖에서 받는다 (`now`, epoch ms). 시계를 안에 두지 않아야 테스트가 시간을 마음대로 옮긴다
 * - 두 플랫폼이 이 한 벌을 쓴다 — 웜업 자동 넘김 · 일시정지 셈이 플랫폼마다 어긋날 수 없다
 */
data class SessionClock(
    /** 단계마다 시간으로 재는 길이(초). **`0` 이면 분량으로 재는 단계**다 — 사람이 넘긴다 */
    val stepSeconds: List<Int>,
    /** 지금 단계 */
    val index: Int,
    /** 세션을 시작한 시각 (epoch ms) */
    val startedAt: Long,
    /** 멈춰 있던 시간의 합 (ms). **지금 멈춰 있는 구간은 아직 안 들어 있다** */
    val pausedTotal: Long,
    /** 멈춘 시각 (epoch ms). 흐르는 중이면 [NOT_PAUSED] */
    val pausedAt: Long,
    /** 지금 단계에 들어온 순간의 **흐른 시간** (ms) — 단계 안에서 얼마나 지났는지의 기준점 */
    val stepEnteredAt: Long,
    /** 마지막 단계를 넘겼다 */
    val finished: Boolean,
) {
    val isPlaying: Boolean get() = pausedAt == NOT_PAUSED

    /** 시간으로 재는 단계인가 (웜업) */
    val isTimed: Boolean get() = stepSeconds[index] > 0

    /** 멈춘 시간을 뺀 **흐른 시간** (ms) */
    fun elapsed(now: Long): Long =
        ((if (isPlaying) now else pausedAt) - startedAt - pausedTotal).coerceAtLeast(0)

    fun elapsedSeconds(now: Long): Int = (elapsed(now) / 1000).toInt()

    /**
     * 이 단계에 남은 시간 (초). 분량 단계면 `0`.
     *
     * **올림**이다 — 들어온 순간엔 `72` 를 그대로 보이고, 1초가 다 지나야 `71` 이 된다.
     * 1초마다 빼던 전 화면과 같은 박자다
     */
    fun remainSeconds(now: Long): Int = ((remainMillis(now) + 999) / 1000).toInt()

    /** 이 단계에 남은 시간 (ms). 분량 단계면 `0` — 잠금화면 카운트다운이 **끝나는 시각**을 여기서 잡는다 */
    fun remainMillis(now: Long): Long =
        if (!isTimed) 0
        else (stepSeconds[index] * 1000L - (elapsed(now) - stepEnteredAt)).coerceAtLeast(0)

    fun pause(now: Long): SessionClock = if (isPlaying) copy(pausedAt = now) else this

    fun resume(now: Long): SessionClock =
        if (isPlaying) this
        else copy(pausedTotal = pausedTotal + (now - pausedAt), pausedAt = NOT_PAUSED)

    /** 재생 버튼 — **세션 전체가 같이 선다** (총 경과와 웜업 시계가 함께) */
    fun toggle(now: Long): SessionClock = if (isPlaying) pause(now) else resume(now)

    /** 사람이 넘긴다 (`⏮` `⏭`). 들어간 단계의 시계는 처음부터다. 마지막을 넘기면 [finished] */
    fun moveTo(target: Int, now: Long): SessionClock =
        if (target > stepSeconds.lastIndex) copy(finished = true)
        else copy(index = target.coerceAtLeast(0), stepEnteredAt = elapsed(now))

    fun next(now: Long): SessionClock = moveTo(index + 1, now)

    fun previous(now: Long): SessionClock = moveTo(index - 1, now)

    /**
     * 시간이 다 된 단계를 **스스로 넘긴다** — 웜업.
     *
     * 틱마다 부르지만 틱에 기대지 않는다. 폰이 잠겨 몇 분 멈춰 있다 돌아와도
     * 그 사이 끝났어야 할 단계를 **한 번에 여러 개** 넘긴다.
     * 다음 단계는 *앞 단계가 끝난 시각*에서 시작한다 — 돌아온 시각에서 시작하면 멈춰 있던 만큼 웜업이 늘어난다
     */
    fun catchUp(now: Long): SessionClock {
        val at = elapsed(now)
        var clock = this
        while (!clock.finished && clock.isTimed) {
            val end = clock.stepEnteredAt + clock.stepSeconds[clock.index] * 1000L
            if (at < end) break
            clock = if (clock.index >= stepSeconds.lastIndex) clock.copy(finished = true)
            else clock.copy(index = clock.index + 1, stepEnteredAt = end)
        }
        return clock
    }

    companion object {
        const val NOT_PAUSED: Long = -1L

        /** Swift 에는 기본 인자가 넘어가지 않아 시작은 이 하나로 연다 */
        fun start(stepSeconds: List<Int>, now: Long): SessionClock {
            require(stepSeconds.isNotEmpty()) { "단계가 하나도 없다" }
            return SessionClock(
                stepSeconds = stepSeconds,
                index = 0,
                startedAt = now,
                pausedTotal = 0,
                pausedAt = NOT_PAUSED,
                stepEnteredAt = 0,
                finished = false,
            )
        }
    }
}
