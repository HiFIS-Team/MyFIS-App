"""지점 평면도(M-08)를 **두 플랫폼에 한 번에** 굽는다.

    python3 tools/floorplan/gen_floorplan.py

좌표를 두 번 적으면 한쪽만 고쳐지는 날이 온다. **여기가 유일한 원본**이다.

⚠️ **단위는 미터가 아니다.** SPEC M-08 에서 "재지 않고 보고 그린다"로 정했다 —
숫자는 **그림 안의 자리**일 뿐이고, 실제와 맞아야 하는 건 셋뿐이다:
상대 위치 / 뚫린 곳·막힌 곳 / 어느 구역에 몇 대.

지금 것은 **200평 헬스장을 가정한 견본**이다 (사용자 제공 레퍼런스를 보고 그렸다).
지점 사진이 들어오면 이 파일의 숫자만 바꾼다.
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

W, H = 300.0, 224.0

# 바깥 벽. **닫힌 도형이 아니라 열린 선**이다 — 아래쪽 출입구에서 끊긴다.
# 왼쪽 위가 꺾인 건 레퍼런스를 따른 것이다. 네모반듯하면 어느 지점이든 같아 보인다
OUTLINE = [
    (176, 224), (300, 224), (300, 0), (18, 0), (18, 26), (0, 26), (0, 224), (134, 224),
]

# 구역 — (이름, x, y, w, h, 색)
ZONES = [
    ("카디오존", 10, 10, 190, 54, "green"),
    ("스트레칭존", 208, 10, 84, 54, "teal"),
    ("프리웨이트존", 10, 72, 104, 102, "violet"),
    ("머신존", 122, 72, 112, 102, "blue"),
    ("PT존", 242, 72, 50, 50, "orange"),
    ("휴게존", 242, 130, 50, 44, "gold"),
]

# 아래 띠의 방들 — (이름, x, y, w, h, 색)
# ⚠️ 이름은 **두 줄**이다. 한 줄로 두면 옆방 이름과 겹쳐 서로 못 읽는다
ROOMS = [
    ("여자\\n탈의실", 0, 182, 48, 42, "pink"),
    ("여자\\n샤워실", 48, 182, 48, 42, "pink"),
    ("화장실", 96, 182, 38, 42, "gray"),
    ("계단", 176, 182, 28, 42, "gray"),
    ("엘리\\n베이터", 204, 182, 28, 42, "gray"),
    ("남자\\n샤워실", 232, 182, 34, 42, "blue"),
    ("남자\\n탈의실", 266, 182, 34, 42, "blue"),
]

# 출입구 — 벽이 끊긴 자리. 라임은 이 화면에서 **찾기 줄 다음 두 번째**다 (§3.2)
ENTRANCE = (155.0, 205.0)

BODY, CAP, PILLAR, PLANT = 0, 1, 2, 3

items = []


def box(x, y, w, h, r=3.0, tone=BODY):
    items.append((x, y, w, h, r, tone))


def dot(cx, cy, d, tone=BODY):
    items.append((cx - d / 2, cy - d / 2, d, d, d / 2, tone))


# ── 카디오존 ───────────────────────────────────────────────────────────────
# 러닝머신 다섯. **머리쪽에 계기판**을 얹어야 위아래가 생긴다
for x in (18, 38, 58, 78, 98):
    box(x, 26, 14, 32)
    box(x + 2, 26, 10, 7, 2, CAP)
# 사이클 넷
for x in (122, 142, 162, 182):
    box(x + 1, 34, 12, 24)
    dot(x + 7, 30, 11, CAP)

# ── 스트레칭존 ─────────────────────────────────────────────────────────────
for x in (216, 240, 264):
    box(x, 26, 20, 28, 4)
dot(286, 18, 11, PLANT)

# ── 프리웨이트존 ───────────────────────────────────────────────────────────
# ⚠️ 물건을 구역 **맨 위**에 붙이지 않는다. 구역 이름이 그 자리에 앉는다
box(16, 90, 12, 30)          # 덤벨 랙 둘
box(16, 126, 12, 30)
box(34, 90, 22, 22)          # 스쿼트랙
box(34, 90, 22, 6, 3, CAP)
box(34, 122, 22, 24)         # 벤치프레스
box(38, 128, 14, 9, 3, CAP)
for y in (92, 110, 128, 146):  # 바벨 넷
    box(66, y, 42, 5, 2.5)
dot(20, 165, 12, PLANT)

# ── 머신존 ────────────────────────────────────────────────────────────────
# 다섯 × 두 줄. **줄을 맞춰 둔다** — 어긋나면 통로가 어디인지 안 보인다
for y in (92, 134):
    for x in (130, 152, 174, 196, 218):
        box(x, y, 14, 22)
        box(x + 2, y, 10, 6, 2, CAP)

# ── PT존 ─────────────────────────────────────────────────────────────────
box(250, 90, 12, 26)
box(250, 90, 12, 6, 2, CAP)
dot(278, 108, 13)
box(272, 88, 14, 6, 2, CAP)

# ── 휴게존 ────────────────────────────────────────────────────────────────
# ⚠️ 탁자를 구역 한가운데 두면 **구역 이름에 닿는다.** 아래로 내리고 의자는 셋만 둔다
dot(264, 158, 18, CAP)       # 탁자
for cx, cy in ((251, 158), (277, 158), (264, 170)):
    dot(cx, cy, 8)
dot(285, 170, 11, PLANT)

# ── 기둥 ─────────────────────────────────────────────────────────────────
# 실제 건물엔 기둥이 있다. 없으면 도면이 **평면 그래픽**처럼 보인다
for x, y in ((92, 4), (188, 4), (100, 168), (176, 168)):
    box(x, y, 14, 12, 2, PILLAR)


SWIFT = '''import SwiftUI

// ⚠️ 이 파일은 **손으로 고치지 않는다.** `tools/floorplan/gen_floorplan.py` 가 굽는다.
// 안드로이드 쪽(`BranchFloorPlan.kt`)과 **같은 원본에서 나온다** —
// 좌표를 두 번 적으면 한쪽만 고쳐지는 날이 온다.

/// 평면도 안에서 쓰는 색갈래. 실제 색은 그리는 쪽에서 `MyFisColor` 로 푼다
enum PlanTint {{
    case green, teal, violet, blue, orange, gold, pink, gray
}}

/// 판 위의 물건 한 개. `tone` 은 몸통 / 얹은 것 / 기둥 / 화분
enum PlanTone {{
    case body, cap, pillar, plant
}}

struct PlanZone {{
    let title: String
    let rect: CGRect
    let tint: PlanTint
}}

struct PlanItem {{
    let rect: CGRect
    let radius: CGFloat
    let tone: PlanTone
}}

/// 200평 헬스장 견본 (SPEC M-08).
///
/// ⚠️ **단위는 미터가 아니다.** "재지 않고 보고 그린다"로 정했으므로 숫자는 **그림 안의 자리**다.
/// 실제와 맞아야 하는 건 셋뿐 — 상대 위치 / 뚫린 곳·막힌 곳 / 어느 구역에 몇 대.
enum BranchFloorPlan {{
    static let size = CGSize(width: {w}, height: {h})

    /// 바깥 벽. **닫힌 도형이 아니라 열린 선**이다 — 아래쪽 출입구에서 끊긴다
    static let outline: [CGPoint] = [
{outline}
    ]

    /// 출입구 — 벽이 끊긴 자리에 서는 핀
    static let entrance = CGPoint(x: {ex}, y: {ey})

    static let zones: [PlanZone] = [
{zones}
    ]

    /// 아래 띠의 방들. 구역과 달리 **벽으로 막혀 있다**
    static let rooms: [PlanZone] = [
{rooms}
    ]

    static let items: [PlanItem] = [
{items}
    ]
}}
'''

KOTLIN = '''package com.myfis.app.ui.screens

// ⚠️ 이 파일은 **손으로 고치지 않는다.** `tools/floorplan/gen_floorplan.py` 가 굽는다.
// iOS 쪽(`BranchFloorPlan.swift`)과 **같은 원본에서 나온다** —
// 좌표를 두 번 적으면 한쪽만 고쳐지는 날이 온다.

/** 평면도 안에서 쓰는 색갈래. 실제 색은 그리는 쪽에서 `MyFisColor` 로 푼다 */
enum class PlanTint {{ GREEN, TEAL, VIOLET, BLUE, ORANGE, GOLD, PINK, GRAY }}

/** 판 위의 물건 한 개. 몸통 / 얹은 것 / 기둥 / 화분 */
enum class PlanTone {{ BODY, CAP, PILLAR, PLANT }}

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
object BranchFloorPlan {{
    const val WIDTH = {w}f
    const val HEIGHT = {h}f

    /** 바깥 벽. **닫힌 도형이 아니라 열린 선**이다 — 아래쪽 출입구에서 끊긴다 */
    val outline = listOf(
{outline}
    )

    /** 출입구 — 벽이 끊긴 자리에 서는 핀 */
    const val ENTRANCE_X = {ex}f
    const val ENTRANCE_Y = {ey}f

    val zones = listOf(
{zones}
    )

    /** 아래 띠의 방들. 구역과 달리 **벽으로 막혀 있다** */
    val rooms = listOf(
{rooms}
    )

    val items = listOf(
{items}
    )
}}
'''

TONE_SWIFT = {BODY: ".body", CAP: ".cap", PILLAR: ".pillar", PLANT: ".plant"}
TONE_KT = {BODY: "PlanTone.BODY", CAP: "PlanTone.CAP",
           PILLAR: "PlanTone.PILLAR", PLANT: "PlanTone.PLANT"}


def g(v):
    return f"{round(float(v), 2):g}"


swift = SWIFT.format(
    w=g(W), h=g(H), ex=g(ENTRANCE[0]), ey=g(ENTRANCE[1]),
    outline="\n".join(f"        CGPoint(x: {g(x)}, y: {g(y)})," for x, y in OUTLINE),
    zones="\n".join(
        f'        PlanZone(title: "{t}", rect: CGRect(x: {g(x)}, y: {g(y)},'
        f" width: {g(w)}, height: {g(h)}), tint: .{c})," for t, x, y, w, h, c in ZONES),
    rooms="\n".join(
        f'        PlanZone(title: "{t}", rect: CGRect(x: {g(x)}, y: {g(y)},'
        f" width: {g(w)}, height: {g(h)}), tint: .{c})," for t, x, y, w, h, c in ROOMS),
    items="\n".join(
        f"        PlanItem(rect: CGRect(x: {g(x)}, y: {g(y)}, width: {g(w)}, height: {g(h)}),"
        f" radius: {g(r)}, tone: {TONE_SWIFT[t]})," for x, y, w, h, r, t in items),
)

kotlin = KOTLIN.format(
    w=g(W), h=g(H), ex=g(ENTRANCE[0]), ey=g(ENTRANCE[1]),
    outline="\n".join(f"        {g(x)}f to {g(y)}f," for x, y in OUTLINE),
    zones="\n".join(
        f'        PlanZone("{t}", {g(x)}f, {g(y)}f, {g(w)}f, {g(h)}f,'
        f" PlanTint.{c.upper()})," for t, x, y, w, h, c in ZONES),
    rooms="\n".join(
        f'        PlanZone("{t}", {g(x)}f, {g(y)}f, {g(w)}f, {g(h)}f,'
        f" PlanTint.{c.upper()})," for t, x, y, w, h, c in ROOMS),
    items="\n".join(
        f"        PlanItem({g(x)}f, {g(y)}f, {g(w)}f, {g(h)}f, {g(r)}f,"
        f" {TONE_KT[t]})," for x, y, w, h, r, t in items),
)

open(f"{ROOT}/iosApp/iosApp/Screens/BranchFloorPlan.swift", "w").write(swift)
open(f"{ROOT}/androidApp/src/main/kotlin/com/myfis/app/ui/screens/BranchFloorPlan.kt",
     "w").write(kotlin)

print(f"wrote plan — {len(ZONES)} zones, {len(ROOMS)} rooms, {len(items)} items")
