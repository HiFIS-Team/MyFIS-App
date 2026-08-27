package com.myfis.app.ui.screens

// ⚠️ 이 파일은 **손으로 고치지 않는다.** `tools/floorplan/gen_floorplan.py` 가 굽는다.
// iOS 쪽(`BranchFloorPlan.swift`)과 **같은 원본에서 나온다** —
// 좌표를 두 번 적으면 한쪽만 고쳐지는 날이 온다.

/** 평면도 안에서 쓰는 색갈래. 실제 색은 그리는 쪽에서 `MyFisColor` 로 푼다 */
enum class PlanTint { GREEN, TEAL, VIOLET, BLUE, ORANGE, GOLD, PINK, GRAY }

/** 판 위의 물건 한 개. 몸통 / 얹은 것 / 기둥 / 화분 */
enum class PlanTone { BODY, CAP, PILLAR, PLANT }

data class PlanZone(
    val title: String,
    val x: Float,
    val y: Float,
    val w: Float,
    val h: Float,
    val tint: PlanTint,
)

data class PlanItem(
    val x: Float,
    val y: Float,
    val w: Float,
    val h: Float,
    val radius: Float,
    val tone: PlanTone,
)

/**
 * 200평 헬스장 견본 (SPEC M-08).
 *
 * ⚠️ **단위는 미터가 아니다.** "재지 않고 보고 그린다"로 정했으므로 숫자는 **그림 안의 자리**다.
 * 실제와 맞아야 하는 건 셋뿐 — 상대 위치 / 뚫린 곳·막힌 곳 / 어느 구역에 몇 대.
 */
object BranchFloorPlan {
    const val WIDTH = 300f
    const val HEIGHT = 224f

    /** 바깥 벽. **닫힌 도형이 아니라 열린 선**이다 — 아래쪽 출입구에서 끊긴다 */
    val outline = listOf(
        176f to 224f,
        300f to 224f,
        300f to 0f,
        18f to 0f,
        18f to 26f,
        0f to 26f,
        0f to 224f,
        134f to 224f,
    )

    /** 출입구 — 벽이 끊긴 자리에 서는 핀 */
    const val ENTRANCE_X = 155f
    const val ENTRANCE_Y = 205f

    /** 내가 선 자리. **재서 얻은 값이 아니라 마지막으로 아는 자리**다 (SPEC M-08) */
    const val MY_X = 155f
    const val MY_Y = 196f

    val zones = listOf(
        PlanZone("카디오존", 10f, 10f, 190f, 54f, PlanTint.GREEN),
        PlanZone("스트레칭존", 208f, 10f, 84f, 54f, PlanTint.TEAL),
        PlanZone("프리웨이트존", 10f, 72f, 104f, 102f, PlanTint.VIOLET),
        PlanZone("머신존", 122f, 72f, 112f, 102f, PlanTint.BLUE),
        PlanZone("PT존", 242f, 72f, 50f, 50f, PlanTint.ORANGE),
        PlanZone("휴게존", 242f, 130f, 50f, 44f, PlanTint.GOLD),
    )

    /** 아래 띠의 방들. 구역과 달리 **벽으로 막혀 있다** */
    val rooms = listOf(
        PlanZone("여자\n탈의실", 0f, 182f, 48f, 42f, PlanTint.PINK),
        PlanZone("여자\n샤워실", 48f, 182f, 48f, 42f, PlanTint.PINK),
        PlanZone("화장실", 96f, 182f, 38f, 42f, PlanTint.GRAY),
        PlanZone("계단", 176f, 182f, 28f, 42f, PlanTint.GRAY),
        PlanZone("엘리\n베이터", 204f, 182f, 28f, 42f, PlanTint.GRAY),
        PlanZone("남자\n샤워실", 232f, 182f, 34f, 42f, PlanTint.BLUE),
        PlanZone("남자\n탈의실", 266f, 182f, 34f, 42f, PlanTint.BLUE),
    )

    val items = listOf(
        PlanItem(18f, 26f, 14f, 32f, 3f, PlanTone.BODY),
        PlanItem(20f, 26f, 10f, 7f, 2f, PlanTone.CAP),
        PlanItem(38f, 26f, 14f, 32f, 3f, PlanTone.BODY),
        PlanItem(40f, 26f, 10f, 7f, 2f, PlanTone.CAP),
        PlanItem(58f, 26f, 14f, 32f, 3f, PlanTone.BODY),
        PlanItem(60f, 26f, 10f, 7f, 2f, PlanTone.CAP),
        PlanItem(78f, 26f, 14f, 32f, 3f, PlanTone.BODY),
        PlanItem(80f, 26f, 10f, 7f, 2f, PlanTone.CAP),
        PlanItem(98f, 26f, 14f, 32f, 3f, PlanTone.BODY),
        PlanItem(100f, 26f, 10f, 7f, 2f, PlanTone.CAP),
        PlanItem(123f, 34f, 12f, 24f, 3f, PlanTone.BODY),
        PlanItem(123.5f, 24.5f, 11f, 11f, 5.5f, PlanTone.CAP),
        PlanItem(143f, 34f, 12f, 24f, 3f, PlanTone.BODY),
        PlanItem(143.5f, 24.5f, 11f, 11f, 5.5f, PlanTone.CAP),
        PlanItem(163f, 34f, 12f, 24f, 3f, PlanTone.BODY),
        PlanItem(163.5f, 24.5f, 11f, 11f, 5.5f, PlanTone.CAP),
        PlanItem(183f, 34f, 12f, 24f, 3f, PlanTone.BODY),
        PlanItem(183.5f, 24.5f, 11f, 11f, 5.5f, PlanTone.CAP),
        PlanItem(216f, 26f, 20f, 28f, 4f, PlanTone.BODY),
        PlanItem(240f, 26f, 20f, 28f, 4f, PlanTone.BODY),
        PlanItem(264f, 26f, 20f, 28f, 4f, PlanTone.BODY),
        PlanItem(280.5f, 12.5f, 11f, 11f, 5.5f, PlanTone.PLANT),
        PlanItem(16f, 90f, 12f, 30f, 3f, PlanTone.BODY),
        PlanItem(16f, 126f, 12f, 30f, 3f, PlanTone.BODY),
        PlanItem(34f, 90f, 22f, 22f, 3f, PlanTone.BODY),
        PlanItem(34f, 90f, 22f, 6f, 3f, PlanTone.CAP),
        PlanItem(34f, 122f, 22f, 24f, 3f, PlanTone.BODY),
        PlanItem(38f, 128f, 14f, 9f, 3f, PlanTone.CAP),
        PlanItem(66f, 92f, 42f, 5f, 2.5f, PlanTone.BODY),
        PlanItem(66f, 110f, 42f, 5f, 2.5f, PlanTone.BODY),
        PlanItem(66f, 128f, 42f, 5f, 2.5f, PlanTone.BODY),
        PlanItem(66f, 146f, 42f, 5f, 2.5f, PlanTone.BODY),
        PlanItem(14f, 159f, 12f, 12f, 6f, PlanTone.PLANT),
        PlanItem(130f, 92f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(132f, 92f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(152f, 92f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(154f, 92f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(174f, 92f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(176f, 92f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(196f, 92f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(198f, 92f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(218f, 92f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(220f, 92f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(130f, 134f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(132f, 134f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(152f, 134f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(154f, 134f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(174f, 134f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(176f, 134f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(196f, 134f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(198f, 134f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(218f, 134f, 14f, 22f, 3f, PlanTone.BODY),
        PlanItem(220f, 134f, 10f, 6f, 2f, PlanTone.CAP),
        PlanItem(250f, 90f, 12f, 26f, 3f, PlanTone.BODY),
        PlanItem(250f, 90f, 12f, 6f, 2f, PlanTone.CAP),
        PlanItem(271.5f, 101.5f, 13f, 13f, 6.5f, PlanTone.BODY),
        PlanItem(272f, 88f, 14f, 6f, 2f, PlanTone.CAP),
        PlanItem(255f, 149f, 18f, 18f, 9f, PlanTone.CAP),
        PlanItem(247f, 154f, 8f, 8f, 4f, PlanTone.BODY),
        PlanItem(273f, 154f, 8f, 8f, 4f, PlanTone.BODY),
        PlanItem(260f, 166f, 8f, 8f, 4f, PlanTone.BODY),
        PlanItem(279.5f, 164.5f, 11f, 11f, 5.5f, PlanTone.PLANT),
        PlanItem(92f, 4f, 14f, 12f, 2f, PlanTone.PILLAR),
        PlanItem(188f, 4f, 14f, 12f, 2f, PlanTone.PILLAR),
        PlanItem(100f, 168f, 14f, 12f, 2f, PlanTone.PILLAR),
        PlanItem(176f, 168f, 14f, 12f, 2f, PlanTone.PILLAR),
    )
}
