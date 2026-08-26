"""혜택 행의 **원색 아이콘**을 두 플랫폼에 한 번에 굽는다.

    python3 tools/icons/gen_color_icons.py

`ic_benefit_*` 대부분은 색이 없는 **채움 두 톤**(→ `gen_benefit_icons.py`)이고 tint 로 색이 바뀐다.
여기 있는 것들은 **자기 색을 가진 그림**이다 — 브랜드 마크(인스타)나 캐릭터(AI 봇)라
한 색으로 눌러 버리면 그림이 아니라 실루엣이 된다. 쓰는 쪽에서 tint 를 걸지 않는다
(`BenefitKind.colorIcon == true`).
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


def ellipse(cx, cy, rx, ry):
    return (f"M{n(cx-rx)},{n(cy)} a{n(rx)},{n(ry)} 0 1,1 {n(2*rx)},0"
            f" a{n(rx)},{n(ry)} 0 1,1 {n(-2*rx)},0 Z")


# ── 인스타 ────────────────────────────────────────────────────────────────
# 바깥 둥근 네모 테 + 가운데 원 테 + 오른쪽 위 점. 셋 다 **한 그라디언트**로 칠한다.
# 구멍은 evenodd — 테 안쪽이 뚫려야 로고다
INSTA_PATH = " ".join([
    rrect(0.9, 0.9, 22.2, 22.2, 6.9),   # 바깥 모서리
    rrect(3.5, 3.5, 17.0, 17.0, 4.5),   # 안쪽 (구멍)
    circ(12, 12, 6.3),                  # 렌즈 바깥
    circ(12, 12, 3.85),                 # 렌즈 안 (구멍)
    circ(18.7, 5.5, 1.5),               # 점
])
# 왼쪽 아래에서 퍼지는 방사형 — 인스타 마크의 원래 방식이다 (선형으로 깔면 노랑이 죽는다)
INSTA_GRADIENT = dict(
    type="radial", cx=2.5, cy=22.5, r=30,
    stops=[(0.0, "#FFDB2C"), (0.3, "#FF7A2F"), (0.55, "#FF1B44"),
           (0.78, "#F0007E"), (1.0, "#C800CA")],
)

# ── AI 봇 ─────────────────────────────────────────────────────────────────
BOT_BAND = "#C2CCD2"    # 헤드셋 띠
BOT_CUP = "#2B7FFF"     # 귀
BOT_HEAD = "#DEE5EA"    # 머리
BOT_FACE = "#123A5E"    # 얼굴 판 · 마이크
BOT_EYE = "#2BD9F5"     # 눈 · 입

BOT = [
    # 띠는 **선**이다. 면으로 그리면 두께를 두 번 관리해야 한다
    ("stroke", "M2.3,12.8 V9.1 A9.7,7.5 0 0,1 21.7,9.1 V20 A1.7,1.7 0 0,1 20,21.7 H16.8",
     BOT_BAND, 1.3),
    ("fill", rrect(11.4, 20.2, 5.4, 3.2, 1.6), BOT_FACE, None),          # 마이크
    ("fill", rrect(4.7, 6.6, 1.5, 3.4, 0.75), BOT_HEAD, None),           # 더듬이 왼
    ("fill", rrect(17.8, 6.6, 1.5, 3.4, 0.75), BOT_HEAD, None),          # 더듬이 오른
    ("fill", rrect(0.6, 12.1, 3.6, 7.1, 1.1), BOT_CUP, None),            # 귀 왼
    ("fill", rrect(19.8, 12.1, 3.6, 7.1, 1.1), BOT_CUP, None),           # 귀 오른
    ("fill", rrect(4.7, 8.9, 14.5, 11.0, 2.3), BOT_HEAD, None),          # 머리
    # 얼굴 윗변은 **두 번 봉긋하고 가운데가 팬다** — 직선으로 자르면 로봇이 아니라 상자다
    ("fill", "M6,13.2 C6,11.6 6.9,10.5 8.1,10.5 C9.3,10.5 9.9,11.5 12,11.5"
             " C14.1,11.5 14.7,10.5 15.9,10.5 C17.1,10.5 18,11.6 18,13.2"
             " V17.1 A1.9,1.9 0 0,1 16.1,19 H7.9 A1.9,1.9 0 0,1 6,17.1 Z", BOT_FACE, None),
    ("fill", ellipse(8.9, 14.8, 1.05, 1.4), BOT_EYE, None),              # 눈 왼
    ("fill", ellipse(15.2, 14.8, 1.05, 1.4), BOT_EYE, None),             # 눈 오른
    ("stroke", "M10.95,16.3 Q12,17.5 13.05,16.3", BOT_EYE, 0.8),         # 입
]

# ── 웨이트 (벤치프레스 랙) ────────────────────────────────────────────────
W_PLATE_OUT = "#3D566E"
W_PLATE_IN = "#2C4054"
W_BAR = "#E2E6E9"
W_POST = "#C6CDD3"
W_HOOK = "#8B99A3"
W_SEAT = "#8CADFF"
W_STEM = "#6E8090"
W_STEM_TOP = "#5B6E7C"
W_FOOT = "#77878F"

# 뒤에서 앞으로 쌓는다 — 발 → 기둥 → 걸이 → 바 → 원판 → 벤치
WEIGHT = [
    ("fill", rrect(5.5, 17.6, 3.5, 0.75, 0.37), W_FOOT, None),
    ("fill", rrect(10.9, 17.6, 2.2, 0.75, 0.37), W_FOOT, None),
    ("fill", rrect(14.9, 17.6, 3.5, 0.75, 0.37), W_FOOT, None),
    ("fill", rrect(11.25, 15.4, 1.45, 2.5, 0.1), W_STEM, None),
    ("fill", rrect(11.25, 15.4, 1.45, 0.9, 0.1), W_STEM_TOP, None),
    ("fill", rrect(6.8, 5.7, 1.6, 12.4, 0.8), W_POST, None),
    ("fill", rrect(15.9, 5.7, 1.6, 12.4, 0.8), W_POST, None),
    ("fill", rrect(8.3, 11.15, 1.5, 0.62, 0.31), W_HOOK, None),
    ("fill", rrect(14.2, 11.15, 1.5, 0.62, 0.31), W_HOOK, None),
    ("fill", rrect(4.6, 7.6, 15.2, 1.7, 0.1), W_BAR, None),
    ("fill", rrect(1.9, 6.3, 1.8, 3.8, 0.7), W_PLATE_OUT, None),
    ("fill", rrect(20.3, 6.3, 1.8, 3.8, 0.7), W_PLATE_OUT, None),
    ("fill", rrect(3.4, 5.5, 2.5, 5.4, 0.8), W_PLATE_IN, None),
    ("fill", rrect(18.1, 5.5, 2.5, 5.4, 0.8), W_PLATE_IN, None),
    ("fill", rrect(9.5, 13.2, 5, 2.4, 0.8), W_SEAT, None),
]

# ── 유산소 (러닝머신) ─────────────────────────────────────────────────────
C_LINE = "#B9CCFB"
C_BODY = "#4A6285"
C_DARK = "#3B5170"
C_MINT = "#5CDCC0"

CARDIO = [
    ("fill", rrect(5.6, 10.1, 7.5, 0.8, 0.4), C_LINE, None),      # 속도선 — 어긋나게 놓는다
    ("fill", rrect(3.5, 11.7, 7.5, 0.8, 0.4), C_LINE, None),
    ("fill", rrect(6.9, 13.3, 6.9, 0.8, 0.4), C_LINE, None),
    ("fill", "M16.7,6.6 L18,2.9 h1.9 L18.6,6.6 Z", C_MINT, None),  # 계기판
    ("fill", rrect(12.4, 6.1, 8, 1.6, 0.8), C_BODY, None),         # 손잡이
    ("fill", "M18.5,6.9 H20.3 L22.1,16.6 H20.2 Z", C_BODY, None),  # 기둥
    ("fill", rrect(0.4, 17.2, 23.2, 4, 1.2), C_BODY, None),        # 바닥
    ("fill", "M15.2,18.6 L19.5,16.2 H20.8 L23.4,18.6 Z", C_MINT, None),  # 기둥 밑동
    ("fill", rrect(0.4, 16.2, 4.4, 3, 1), C_DARK, None),           # 왼쪽 단
    ("fill", "M1.7,21.2 H5.4 L4.7,22.4 H2.4 Z", C_DARK, None),     # 발
    ("fill", "M15.8,21.2 H21.6 L20.9,22.4 H16.5 Z", C_DARK, None),
]

ANDROID_HEAD = ('<?xml version="1.0" encoding="utf-8"?>\n'
                '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
                '{extra}    android:width="24dp"\n'
                '    android:height="24dp"\n'
                '    android:viewportWidth="24"\n'
                '    android:viewportHeight="24">\n')


def write(name, android_body, svg_body, aapt=False):
    extra = '    xmlns:aapt="http://schemas.android.com/aapt"\n' if aapt else ""
    open(f"{ANDROID}/{name}.xml", "w").write(
        ANDROID_HEAD.format(extra=extra) + android_body + "</vector>\n")
    folder = f"{IOS}/{name}.imageset"
    os.makedirs(folder, exist_ok=True)
    open(f"{folder}/{name}.svg", "w").write(
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">\n'
        + svg_body + '</svg>\n')
    open(f"{folder}/Contents.json", "w").write(json.dumps({
        "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        # **original** 이다 — template 로 두면 tint 한 색으로 눌려 그림이 사라진다
        "properties": {"preserves-vector-representation": True,
                       "template-rendering-intent": "original"},
    }, indent=2) + "\n")


# 인스타
g = INSTA_GRADIENT
items = "".join(
    f'                <item android:offset="{o}" android:color="{c}" />\n' for o, c in g["stops"])
android = (f'    <path\n        android:pathData="{INSTA_PATH}"\n'
           f'        android:fillType="evenOdd">\n'
           f'        <aapt:attr name="android:fillColor">\n'
           f'            <gradient\n'
           f'                android:type="radial"\n'
           f'                android:centerX="{g["cx"]}"\n'
           f'                android:centerY="{g["cy"]}"\n'
           f'                android:gradientRadius="{g["r"]}">\n'
           f'{items}'
           f'            </gradient>\n'
           f'        </aapt:attr>\n'
           f'    </path>\n')
stops = "".join(f'      <stop offset="{o}" stop-color="{c}"/>\n' for o, c in g["stops"])
svg = ('  <defs>\n'
       f'    <radialGradient id="ig" cx="{g["cx"]}" cy="{g["cy"]}" r="{g["r"]}"'
       ' gradientUnits="userSpaceOnUse">\n'
       f'{stops}'
       '    </radialGradient>\n'
       '  </defs>\n'
       f'  <path d="{INSTA_PATH}" fill="url(#ig)" fill-rule="evenodd"/>\n')
write("ic_benefit_sns", android, svg, aapt=True)

# AI 봇
android, svg = "", ""
for kind, d, color, w in BOT:
    if kind == "fill":
        android += (f'    <path\n        android:pathData="{d}"\n'
                    f'        android:fillColor="{color}" />\n')
        svg += f'  <path d="{d}" fill="{color}"/>\n'
    else:
        android += (f'    <path\n        android:pathData="{d}"\n'
                    f'        android:strokeWidth="{w}"\n'
                    f'        android:strokeColor="{color}"\n'
                    f'        android:strokeLineCap="round"\n'
                    f'        android:strokeLineJoin="round" />\n')
        svg += (f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="{w}"'
                ' stroke-linecap="round" stroke-linejoin="round"/>\n')
write("ic_benefit_quiz", android, svg)


def bake(name, parts):
    android, svg = "", ""
    for kind, d, color, w in parts:
        if kind == "fill":
            android += (f'    <path\n        android:pathData="{d}"\n'
                        f'        android:fillColor="{color}" />\n')
            svg += f'  <path d="{d}" fill="{color}"/>\n'
        else:
            android += (f'    <path\n        android:pathData="{d}"\n'
                        f'        android:strokeWidth="{w}"\n'
                        f'        android:strokeColor="{color}"\n'
                        f'        android:strokeLineCap="round"\n'
                        f'        android:strokeLineJoin="round" />\n')
            svg += (f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="{w}"'
                    ' stroke-linecap="round" stroke-linejoin="round"/>\n')
    write(name, android, svg)


# 웨이트 · 유산소는 **행에서만** 원색이다 — 활동 랜딩은 아직 두 톤 벌(`ic_benefit_*`)을 쓴다.
# 그래서 이름을 덮지 않고 `_color` 로 따로 둔다
bake("ic_benefit_routine_color", WEIGHT)
bake("ic_benefit_cardio_color", CARDIO)

print("wrote 4 color icons")
