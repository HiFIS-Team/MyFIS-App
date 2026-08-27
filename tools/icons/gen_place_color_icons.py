"""`기구 찾기`(M-08) 여덟 칸 중 **자기 색을 가진 것**을 굽는다.

    python3 tools/icons/gen_place_color_icons.py

화장실 · 탈의실은 **표지판**이라 색이 곧 뜻이고 (파랑·분홍이 남녀 표시 그 자체다),
머신 · 데스크 · 샤워실은 **사용자가 준 원본이 원색**이다.

쓰는 쪽에서 tint 를 걸지 않는다 (`BranchPlace.colorIcon == true`).

⚠️ 원본이 **아이소메트릭**(비스듬히 본 그림)이어도 그대로 옮기지 않는다. 24px 안에서
비스듬한 면은 전부 얇은 삼각형이 되어 사라진다 — **옆에서 본 그림으로 다시 세운다.**
"""
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"


def n(v):
    return f"{round(v, 3):g}"


def rrect(x, y, w, h, r):
    return (f"M{n(x+r)},{n(y)} h{n(w-2*r)} a{n(r)},{n(r)} 0 0,1 {n(r)},{n(r)}"
            f" v{n(h-2*r)} a{n(r)},{n(r)} 0 0,1 {n(-r)},{n(r)} h{n(-(w-2*r))}"
            f" a{n(r)},{n(r)} 0 0,1 {n(-r)},{n(-r)} v{n(-(h-2*r))}"
            f" a{n(r)},{n(r)} 0 0,1 {n(r)},{n(-r)} Z")


def circ(cx, cy, r):
    return (f"M{n(cx-r)},{n(cy)} a{n(r)},{n(r)} 0 1,1 {n(2*r)},0"
            f" a{n(r)},{n(r)} 0 1,1 {n(-2*r)},0 Z")


# ── 화장실 ────────────────────────────────────────────────────────────────
T_MAN = "#4BA9F0"
T_WOMAN = "#E8447D"
T_BAR = "#7C8C99"

# 가르는 막대가 **꼭 있어야 한다.** 빼면 사람 둘이 나란히 선 그림이 되고,
# 그건 PT존(사람 + 덤벨)과 같은 칸에서 헷갈린다
TOILET = [
    ("fill", circ(4.95, 4.15, 2.95), T_MAN),                       # 남 머리
    ("fill", "M1.35,11.1 a3.4,3.4 0 0 1 3.4,-3.4 h0.4"
             " a3.4,3.4 0 0 1 3.4,3.4 v6.3 a1,1 0 0 1 -1,1"
             " h-5.2 a1,1 0 0 1 -1,-1 Z", T_MAN),                  # 남 몸
    ("fill", "M2.75,18.4 h1.55 v2.95 a0.775,0.775 0 0 1 -1.55,0 Z", T_MAN),
    ("fill", "M5.6,18.4 h1.55 v2.95 a0.775,0.775 0 0 1 -1.55,0 Z", T_MAN),
    ("fill", rrect(11.25, 1.1, 1.5, 21.8, 0.75), T_BAR),           # 가르는 막대
    ("fill", circ(18.4, 4.15, 2.95), T_WOMAN),                     # 여 머리
    # 치마는 **아래로 벌어지는 사다리꼴**이다. 남자 몸과 같은 폭으로 두면 갈라 읽히지 않는다
    ("fill", "M14.4,18.4 L15.5,11 a3.3,3.3 0 0 1 2.9,-3.25"
             " a3.3,3.3 0 0 1 2.9,3.25 L22.4,18.4 Z", T_WOMAN),
    ("fill", "M16.9,18.4 h1.4 v2.95 a0.7,0.7 0 0 1 -1.4,0 Z", T_WOMAN),
    ("fill", "M19.1,18.4 h1.4 v2.95 a0.7,0.7 0 0 1 -1.4,0 Z", T_WOMAN),
]

# ── 탈의실 ────────────────────────────────────────────────────────────────
F_POST = "#FBD24C"
F_ROD = "#3B4046"
F_CURTAIN = "#F5215E"
F_CURTAIN_LIT = "#FF4C7C"
F_SHOE = "#E3E6E8"
F_SOCK = "#8CD22B"

# 부스는 **하나만** 그린다. 원본처럼 둘을 넣으면 28px 에서 한 칸이 6px 가 된다.
#
# ⚠️ 커튼을 **한쪽으로 몰아 친다.** 원본은 커튼이 부스를 거의 다 덮고 발이 손톱만큼 보이는데,
# 그 비율을 그대로 줄이면 28px 에서 발이 **얼룩 한 점**이 된다. 발이 안 보이면 그냥 창문이다
FITTING = [
    ("fill", rrect(1.5, 1.6, 2.8, 20.8, 0.6), F_POST),             # 왼쪽 기둥
    ("fill", rrect(19.7, 1.6, 2.8, 20.8, 0.6), F_POST),            # 오른쪽 기둥
    ("fill", rrect(4.4, 17.2, 4.2, 4.3, 0.9), F_SHOE),             # 발 — 커튼 왼쪽으로 나온다
    ("fill", rrect(4.4, 17.2, 4.2, 1.5, 0.75), F_SOCK),
    # 아랫단은 **톱니**다. 일자로 자르면 커튼이 아니라 판이 된다
    ("fill", "M8,6 H20.1 V20"
             " l-1.5125,1.4 l-1.5125,-1.4 l-1.5125,1.4 l-1.5125,-1.4"
             " l-1.5125,1.4 l-1.5125,-1.4 l-1.5125,1.4 l-1.5125,-1.4 Z", F_CURTAIN),
    # 맨 왼쪽 폭만 밝게 — 원본의 비치는 결을 한 겹으로 줄인 것이다
    ("fill", "M8,6 H11.025 V20 l-1.5125,1.4 l-1.5125,-1.4 Z", F_CURTAIN_LIT),
    ("fill", rrect(2.9, 4.6, 18.2, 1.8, 0.6), F_ROD),              # 봉 — 커튼 위에 얹는다
]

# ── 머신 ──────────────────────────────────────────────────────────────────
M_FRAME = "#C7D4EE"
M_BAR = "#DEE6F7"
M_PLATE = "#E8352E"
M_PLATE_EDGE = "#C92B25"
M_HUB = "#F9C74F"
M_SEAT = "#474C53"
M_SEAT_LIT = "#5C626B"

# 인클라인 벤치프레스. **빨간 원판**이 프리웨이트(쇳빛 원판)와 갈라 주는 표시다 —
# 같은 랙 모양이라도 색이 다르면 다른 구역으로 읽힌다
MACHINE = [
    ("fill", rrect(3.4, 19.6, 17.2, 1.9, 0.9), M_FRAME),           # 받침
    ("fill", rrect(5.6, 8.2, 1.7, 11.6, 0.6), M_FRAME),            # 왼쪽 기둥
    ("fill", rrect(17, 8.2, 1.7, 11.6, 0.6), M_FRAME),             # 오른쪽 기둥
    # ⚠️ 기둥을 A 자로 기울였더니 바와 꼭짓점이 겹쳐 **이젤**로 읽혔다. 수직으로 세운다
    ("fill", rrect(1.8, 5.2, 20.4, 1.8, 0.9), M_BAR),              # 바 — 기둥 위에 얹힌다
    ("fill", circ(4.2, 6.1, 3.4), M_PLATE_EDGE),                   # 왼쪽 원판
    ("fill", circ(4.2, 6.1, 2.8), M_PLATE),
    ("fill", circ(4.2, 6.1, 1.1), M_HUB),
    ("fill", circ(19.8, 6.1, 3.4), M_PLATE_EDGE),                  # 오른쪽 원판
    ("fill", circ(19.8, 6.1, 2.8), M_PLATE),
    ("fill", circ(19.8, 6.1, 1.1), M_HUB),
    # ⚠️ 등받이를 **비스듬한 판 하나**로 두면 금지 표시의 빗금처럼 읽힌다.
    # **깔개(가로) + 등받이(비스듬)** 두 조각이라야 인클라인 벤치가 된다
    ("fill", rrect(6, 16.4, 7.6, 2.8, 0.7), M_SEAT),               # 깔개
    ("fill", "M11.6,17.4 L16.4,11.4 L18.9,13.4 L14.1,19.4 Z", M_SEAT),   # 등받이
    ("fill", "M11.6,17.4 L16.4,11.4 L17.2,12.1 L12.4,18.1 Z", M_SEAT_LIT),
]

# ── 데스크 ────────────────────────────────────────────────────────────────
D_BODY = "#F0B70E"
D_BODY_EDGE = "#DDA409"
D_BODY_LIT = "#F8CF52"
D_TOP = "#E7E7E9"
D_TOP_EDGE = "#D1D1D5"
D_MONITOR = "#6B6B6B"
D_MONITOR_LIT = "#8C8C8C"
D_CLOCK = "#7C7C7C"
D_FACE = "#F2F2F2"

# 노란 카운터 + 모니터. 시계는 **벽시계**라 데스크를 `프론트` 로 못박아 준다 —
# 다만 28px 에서 바늘은 안 보이므로 **테와 흰 판만** 남긴다
DESK = [
    ("fill", circ(19.6, 4.4, 3.3), D_CLOCK),                       # 벽시계
    ("fill", circ(19.6, 4.4, 2.4), D_FACE),
    ("fill", rrect(19.25, 2.6, 0.7, 2.1, 0.35), D_CLOCK),          # 긴 바늘
    ("fill", rrect(19.25, 4.05, 1.9, 0.7, 0.35), D_CLOCK),         # 짧은 바늘
    ("fill", rrect(6.3, 9.6, 1.4, 2.2, 0), D_MONITOR),             # 모니터 목
    ("fill", rrect(2.3, 3.3, 9.4, 6.9, 1.1), D_MONITOR),           # 모니터
    ("fill", rrect(3.5, 4.5, 0.75, 1.8, 0.37), D_MONITOR_LIT),     # 화면 빛
    ("fill", rrect(1.6, 14.1, 20.8, 8.2, 0.8), D_BODY),            # 카운터 몸통
    ("fill", rrect(20.2, 14.1, 2.2, 8.2, 0.8), D_BODY_EDGE),       # 오른쪽 결
    ("fill", rrect(3.1, 16, 0.75, 2, 0.37), D_BODY_LIT),
    ("fill", rrect(0.7, 11.1, 22.6, 3.3, 0.9), D_TOP),             # 상판 — 몸통보다 넓다
    ("fill", rrect(21.2, 11.1, 2.1, 3.3, 0.9), D_TOP_EDGE),
]

# ── 샤워실 ────────────────────────────────────────────────────────────────
S_PIPE = "#635E66"
S_HEAD = "#F4F4F5"
S_HEAD_EDGE = "#DFDFE1"
S_HEAD_LIT = "#FFFFFF"
S_CAP = "#4F4A54"
S_WATER = "#9EC0F5"

# 물줄기는 **45° 격자**로 뿌린다. 한 줄씩 손으로 놓으면 간격이 흔들려 얼룩이 된다.
#
# `a` 는 흐르는 쪽(머리에서 멀어지는 거리), `b` 는 퍼지는 쪽이다.
# ⚠️ 칸 간격은 **점 길이 + 굵기보다 커야 한다.** 처음엔 성겨서 줄기 예닐곱 개만 남았고,
# 촘촘히 했더니 이번엔 점끼리 붙어 **빗금 친 덩어리**가 됐다. 사이가 보여야 물이다
def _spray():
    out = []
    hx, hy = 8.8, 3.6
    d = 0.7071
    a = 3.8
    while a <= 20:
        b = -9.5
        while b <= 9.5:
            x = hx + d * (a + b)
            y = hy + d * (a - b)
            if 2.6 <= x <= 22.6 and 5.2 <= y <= 22.6:
                out.append(("stroke", f"M{n(x)},{n(y)} L{n(x + 1)},{n(y + 1)}", S_WATER, 1.1))
            b += 3.6
        a += 3.8
    return out


SHOWER = [
    # 파이프는 **벽에서 꺾여 나온다.** 곧은 막대로 두면 어디에 달린 건지 안 보인다
    ("stroke", "M1.4,23 V5.6 a3.4,3.4 0 0 1 3.4,-3.4 h2.2", S_PIPE, 2),
] + _spray() + [
    ("fill", circ(8.8, 3.6, 3.55), S_HEAD_EDGE),
    ("fill", circ(8.8, 3.6, 3.2), S_HEAD),
    ("fill", circ(7.8, 2.4, 1.5), S_HEAD_LIT),                     # 빛
    # 물 나오는 판. **머리 한가운데를 지나게** 두면 반으로 갈린 공이 된다 — 아래쪽으로 밀어 둔다
    ("stroke", "M7.35,6.85 L12.05,2.15", S_CAP, 2),
]

ICONS = {
    "ic_place_toilet": TOILET,
    "ic_place_fitting": FITTING,
    "ic_place_machine": MACHINE,
    "ic_place_desk": DESK,
    "ic_place_shower": SHOWER,
}

ANDROID_HEAD = ('<?xml version="1.0" encoding="utf-8"?>\n'
                '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
                '    android:width="24dp"\n'
                '    android:height="24dp"\n'
                '    android:viewportWidth="24"\n'
                '    android:viewportHeight="24">\n')

for name, parts in ICONS.items():
    android, svg = "", ""
    for part in parts:
        kind, d, color = part[:3]
        if kind == "stroke":
            w = part[3]
            android += (f'    <path\n        android:pathData="{d}"\n'
                        f'        android:strokeWidth="{w}"\n'
                        f'        android:strokeColor="{color}"\n'
                        f'        android:strokeLineCap="round"\n'
                        f'        android:strokeLineJoin="round" />\n')
            svg += (f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="{w}"'
                    ' stroke-linecap="round" stroke-linejoin="round"/>\n')
            continue
        android += (f'    <path\n        android:pathData="{d}"\n'
                    f'        android:fillColor="{color}" />\n')
        svg += f'  <path d="{d}" fill="{color}"/>\n'

    open(f"{ANDROID}/{name}.xml", "w").write(ANDROID_HEAD + android + "</vector>\n")
    folder = f"{IOS}/{name}.imageset"
    os.makedirs(folder, exist_ok=True)
    open(f"{folder}/{name}.svg", "w").write(
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">\n'
        + svg + '</svg>\n')
    open(f"{folder}/Contents.json", "w").write(json.dumps({
        "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        # **original** 이다 — template 로 두면 tint 한 색으로 눌려 그림이 사라진다
        "properties": {"preserves-vector-representation": True,
                       "template-rendering-intent": "original"},
    }, indent=2) + "\n")

print("wrote", len(ICONS), "icons")
