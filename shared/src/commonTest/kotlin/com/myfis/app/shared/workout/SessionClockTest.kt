package com.myfis.app.shared.workout

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class SessionClockTest {
    /** 웜업 60초 둘 + 분량 단계 둘 */
    private val steps = listOf(60, 60, 0, 0)
    private val t0 = 1_000_000L
    private val start = SessionClock.start(steps, t0)

    @Test
    fun 시작하면_웜업을_꽉_채워_보인다() {
        assertEquals(60, start.remainSeconds(t0))
        assertEquals(0, start.elapsedSeconds(t0))
        assertTrue(start.isPlaying)
    }

    @Test
    fun 남은_시간은_올림이다() {
        assertEquals(60, start.remainSeconds(t0 + 500))
        assertEquals(59, start.remainSeconds(t0 + 1_000))
    }

    @Test
    fun 폰이_잠겨_있던_사이_끝난_웜업을_한번에_넘긴다() {
        val back = start.catchUp(t0 + 130_000)
        assertEquals(2, back.index)
        assertEquals(130, back.elapsedSeconds(t0 + 130_000))
        assertFalse(back.finished)
    }

    @Test
    fun 다음_웜업은_앞_웜업이_끝난_시각에서_시작한다() {
        val back = start.catchUp(t0 + 61_000)
        assertEquals(1, back.index)
        assertEquals(59, back.remainSeconds(t0 + 61_000))
    }

    @Test
    fun 멈추면_시간도_자동_넘김도_선다() {
        val paused = start.pause(t0 + 10_000)
        assertEquals(0, paused.catchUp(t0 + 500_000).index)
        assertEquals(10, paused.elapsedSeconds(t0 + 500_000))

        val resumed = paused.resume(t0 + 500_000)
        assertEquals(50, resumed.remainSeconds(t0 + 500_000))
        assertEquals(15, resumed.elapsedSeconds(t0 + 505_000))
    }

    @Test
    fun 사람이_넘기면_들어간_단계의_시계는_처음부터다() {
        val moved = start.next(t0 + 20_000)
        assertEquals(1, moved.index)
        assertEquals(60, moved.remainSeconds(t0 + 20_000))
    }

    @Test
    fun 분량_단계는_스스로_넘어가지_않는다() {
        val counted = start.moveTo(2, t0).catchUp(t0 + 10_000_000)
        assertEquals(2, counted.index)
        assertFalse(counted.finished)
        assertEquals(0, counted.remainSeconds(t0 + 10_000_000))
    }

    @Test
    fun 마지막을_넘기면_끝난다() {
        assertTrue(start.moveTo(3, t0).next(t0).finished)
    }

    @Test
    fun 첫_단계에서_이전을_누르면_첫_단계에_남는다() {
        val prev = start.previous(t0 + 5_000)
        assertEquals(0, prev.index)
        assertEquals(60, prev.remainSeconds(t0 + 5_000))
    }

    @Test
    fun 시간으로_재는_마지막_단계가_끝나면_끝난다() {
        assertTrue(SessionClock.start(listOf(30), t0).catchUp(t0 + 30_000).finished)
    }
}
