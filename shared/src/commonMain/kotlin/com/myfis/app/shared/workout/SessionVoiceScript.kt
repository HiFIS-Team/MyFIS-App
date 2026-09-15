package com.myfis.app.shared.workout

/**
 * 운동 세션 **음성 가이드가 읽는 말** — 두 플랫폼이 한 벌을 쓴다 (DESIGN §6.37).
 *
 * 🟢 (2026-09-15, 사용자 지정 — 안내 음성)
 * - 단계에 들어갈 때 [entering] · 웜업 끝 3초 [countdown] · 마지막을 넘기면 [FINISHED]
 * - 멈춤 · 이어서는 말하지 않는다 — 누른 사람이 이미 안다
 * - **화면 글자를 그대로 읽히지 않는다.** `1 / 5` · `×` · `4세트` 는 들으면 어색하게 읽혀서 **들을 말로 다시 쓴다**
 *   (`다섯 개 중 첫 번째` · 쉼표 · `네 세트`)
 * - 렙 카운트는 아직 없다 — 세트 · 휴식이 생긴 뒤 (SPEC 열린 질문 18)
 */
object SessionVoiceScript {
    /** 마지막 단계를 넘겼을 때 — 완료 토스트와 같은 말이다 */
    const val FINISHED = "오늘 운동을 마쳤어요"

    /**
     * 단계에 들어갈 때.
     * - `웜업 스트레칭, 다섯 개 중 첫 번째. 목 돌리기. 1분 12초`
     * - `운동, 여섯 개 중 두 번째. 스미스 머신 벤치 프레스. 네 세트, 20킬로그램 12회`
     *
     * @param seconds 웜업이면 그 시간, 운동이면 0
     * @param sets 운동이면 세트 수, 웜업이면 0
     * @param load `20kg` — 맨몸이거나 웜업이면 null
     * @param reps 운동이면 횟수, 웜업이면 0
     */
    fun entering(
        warmup: Boolean,
        within: Int,
        total: Int,
        title: String,
        seconds: Int,
        sets: Int,
        load: String?,
        reps: Int,
    ): String {
        val stage = if (warmup) "웜업 스트레칭" else "운동"
        val amount = if (warmup) {
            duration(seconds)
        } else {
            val lift = listOfNotNull(load?.replace("kg", "킬로그램"), "${reps}회").joinToString(" ")
            "${native(sets)} 세트, $lift"
        }
        return "$stage, ${native(total)} 개 중 ${ordinal(within)}. $title. $amount"
    }

    /** 웜업이 끝나기 3초 전부터 — `셋` `둘` `하나`. 그 밖에는 null */
    fun countdown(remainSeconds: Int): String? = when (remainSeconds) {
        3 -> "셋"
        2 -> "둘"
        1 -> "하나"
        else -> null
    }

    /** `1분 12초` · `30초` · `2분` */
    private fun duration(seconds: Int): String =
        listOfNotNull(
            (seconds / 60).takeIf { it > 0 }?.let { "${it}분" },
            (seconds % 60).takeIf { it > 0 }?.let { "${it}초" },
        ).joinToString(" ")

    /** 세는 말 — `네 세트` · `다섯 개`. 열을 넘으면 숫자 그대로 둔다 */
    private fun native(n: Int): String =
        listOf("한", "두", "세", "네", "다섯", "여섯", "일곱", "여덟", "아홉", "열").getOrNull(n - 1) ?: "$n"

    /** `첫 번째` · `두 번째` */
    private fun ordinal(n: Int): String = if (n == 1) "첫 번째" else "${native(n)} 번째"
}
