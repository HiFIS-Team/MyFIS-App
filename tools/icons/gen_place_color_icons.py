"""`기구 찾기`(M-08) 여덟 칸 중 **자기 색을 가진 것**을 굽는다.

    python3 tools/icons/gen_place_color_icons.py

나머지 여섯은 단색 아웃라인(`gen_place_icons.py`)이다. 여기 둘은 **표지판**이라 색이 곧 뜻이다 —
화장실의 파랑·분홍은 남녀 표시 그 자체이고, 탈의실의 커튼은 색이 빠지면 창문으로 읽힌다.

쓰는 쪽에서 tint 를 걸지 않는다 (`BranchPlace.colorIcon == true`).
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

ICONS = {"ic_place_toilet": TOILET, "ic_place_fitting": FITTING}

ANDROID_HEAD = ('<?xml version="1.0" encoding="utf-8"?>\n'
                '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
                '    android:width="24dp"\n'
                '    android:height="24dp"\n'
                '    android:viewportWidth="24"\n'
                '    android:viewportHeight="24">\n')

for name, parts in ICONS.items():
    android, svg = "", ""
    for _kind, d, color in parts:
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
