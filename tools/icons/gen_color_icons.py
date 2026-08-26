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

# ── 체중계 ────────────────────────────────────────────────────────────────
S_BODY = "#8FB8F8"
S_WINDOW = "#E4F1FB"
S_NEEDLE = "#6EA8FA"
S_TICK = "#B8C6D6"
S_FOOT = "#D6E4F5"

SCALE = [
    ("fill", rrect(1.5, 2.9, 21, 18.3, 1.9), S_BODY, None),
    ("fill", rrect(4.9, 4.7, 14.3, 7.6, 0.65), S_WINDOW, None),
    ("stroke", "M12,5.6 V7.4", S_TICK, 0.6),        # 눈금 다섯 — 부채꼴로 벌린다
    ("stroke", "M8.7,6.7 L9.2,8.2", S_TICK, 0.6),
    ("stroke", "M15.3,6.7 L14.8,8.2", S_TICK, 0.6),
    ("stroke", "M6,9.8 L7.6,10.4", S_TICK, 0.6),
    ("stroke", "M18,9.8 L16.4,10.4", S_TICK, 0.6),
    ("fill", "M12,9.3 L11.15,12.3 H12.9 Z", S_NEEDLE, None),   # 바늘
    ("fill", rrect(10.9, 18.4, 2.3, 1, 0.5), S_FOOT, None),    # 앞쪽 버튼
]

# ── 물 마시기 (병 + 잔) ───────────────────────────────────────────────────
W_GLASS = "#BCE2F5"
W_WATER = "#62B4E3"
W_BOTTLE = "#DCF0FA"
W_RIB = "#C6E6F7"
W_NECK = "#BEE3F6"
W_CAP = "#4EA8DC"

# 잔이 뒤, 병이 앞이다 — 겹쳐야 두 개가 한 덩어리로 보인다
GLASS_OUTLINE = ("M12.9,8.1 H21.2 L20.55,22.3 A0.85,0.85 0 0,1 19.7,23.1"
                 " H14.4 A0.85,0.85 0 0,1 13.55,22.3 Z")
WATER = [
    ("fill", GLASS_OUTLINE, W_GLASS, None),
    ("fill", "M13.12,12.9 H20.98 L20.55,22.3 A0.85,0.85 0 0,1 19.7,23.1"
             " H14.4 A0.85,0.85 0 0,1 13.55,22.3 Z", W_WATER, None),
    ("fill", rrect(5.2, 0.8, 4.9, 2.3, 0.5), W_CAP, None),               # 뚜껑
    ("fill", rrect(5.7, 2.6, 3.9, 2.6, 0.3), W_NECK, None),              # 목
    # 어깨는 크게, 바닥은 작게 굴린다 — 위아래가 같으면 병이 아니라 통이다
    ("fill", "M2.9,7.6 a3.2,3.2 0 0,1 3.2,-3.2 h3.8 a3.2,3.2 0 0,1 3.2,3.2"
             " v13.8 a1.9,1.9 0 0,1 -1.9,1.9 h-6.4 a1.9,1.9 0 0,1 -1.9,-1.9 Z",
     W_BOTTLE, None),
    ("fill", rrect(2.8, 8.9, 10.4, 4.2, 0.6), W_WATER, None),            # 라벨
    ("fill", rrect(2.9, 15, 10.2, 0.55, 0.27), W_RIB, None),             # 골
    ("fill", rrect(2.9, 17.2, 10.2, 0.55, 0.27), W_RIB, None),
    ("fill", rrect(2.9, 19.4, 10.2, 0.55, 0.27), W_RIB, None),
]

# ── 뽑기 (네잎클로버) ─────────────────────────────────────────────────────
CL_LEAF = "#4CB81F"
CL_STEM = "#348F12"

# 잎 하나 = 끝이 가운데를 향한 하트. 이걸 90°씩 돌려 넷을 만든다
CLOVER_LEAF = ("M12,11.7 C12,11.7 6.1,7.3 6.1,4.6 a2.95,2.95 0 0,1 5.9,0"
               " a2.95,2.95 0 0,1 5.9,0 c0,2.7 -5.9,7.1 -5.9,7.1 Z")
# 원본의 명암은 **안 옮겼다.** 볼마다 밝기를 주면 잎 넷이 아니라
# **꽃잎 여덟**으로 읽힌다 (그려서 확인). 28px 에서 그 명암은 어차피 안 보인다
CLOVER = [("fill", CLOVER_LEAF, CL_LEAF, None, _rot) for _rot in (0, 90, 180, 270)]
CLOVER += [
    ("fill", rrect(11.5, 6.9, 1, 10.2, 0.1), CL_STEM, None),   # 잎맥 — 십자로 긋는다
    ("fill", rrect(6.9, 11.5, 10.1, 1, 0.1), CL_STEM, None),
]

# ── 스트레칭 (요가 매트) ──────────────────────────────────────────────────
M_MAT = "#BC9BE0"
M_ROLL = "#8E63D0"
M_CORE = "#6D4A9E"
M_CURL = "#5A3D86"
M_DASH = "#7C51C0"

MAT = [
    ("fill", rrect(8.2, 3.8, 15.2, 19.2, 0.5), M_MAT, None),
    ("fill", "M0.4,4.84 a3.9,3.9 0 0,1 7.8,0 V17.4 a3.9,3.9 0 0,1 -7.8,0 Z", M_ROLL, None),
    ("stroke", "M6.35,3.7 V11.7", M_DASH, 0.47),     # 말린 결 — 끊어야 '말려 있다'가 된다
    ("stroke", "M6.35,12.9 V14", M_DASH, 0.47),
    ("fill", circ(4.3, 18.75, 4), M_CORE, None),     # 말린 끝
    ("stroke", "M6.3,18.4 A2.05,2.05 0 1,1 4.15,16.7 A1.15,1.15 0 1,0 3.2,19", M_CURL, 0.62),
]

# ── 옆 사람 터치 (전파 탑) ────────────────────────────────────────────────
T_WAVE = "#D6D7DA"
T_BALL = "#2ECC8F"
T_BALL_DARK = "#24B27C"
T_TOWER = "#5C6079"

# 전파는 공을 중심으로 한 동심원 넷. 안쪽부터 2씩 벌린다
def _wave(r):
    dy, dx = 0.62 * r, (r * r - (0.62 * r) ** 2) ** 0.5
    return (f"M{n(12-dx)},{n(10.6+dy)} A{n(r)},{n(r)} 0 1,1 {n(12+dx)},{n(10.6+dy)}")

TOUCH = [("stroke", _wave(r), T_WAVE, 0.72) for r in (4, 6, 8, 10)] + [
    ("fill", circ(12, 10.6, 2.45), T_BALL, None),
    ("fill", "M12,8.15 a2.45,2.45 0 0,1 0,4.9 Z", T_BALL_DARK, None),
    ("stroke", "M12,12.75 L7.74,23.3 M12,12.75 L16.26,23.3 M7.74,23.3 H16.26",
     T_TOWER, 0.85),                                             # 다리 둘 + 바닥
    ("stroke", "M10.85,15.6 L14.76,19.6 M13.15,15.6 L9.24,19.6", T_TOWER, 0.72),
    ("stroke", "M9.24,19.6 L16.26,23.3 M14.76,19.6 L7.74,23.3", T_TOWER, 0.72),
]

# ── 출석 (달력 + 체크) ────────────────────────────────────────────────────
A_BODY = "#EFEDEC"
A_BAND = "#FC6E5D"
A_RING = "#FCD947"
A_CHECK = "#4A9BF0"

# 몸통 → 머리띠 → 고리 순. 고리는 띠 **위로** 지나가야 달력에 꽂힌 것처럼 보인다
ATTEND = [
    ("fill", rrect(1.13, 2.9, 21.75, 19.98, 2.06), A_BODY, None),
    ("fill", "M1.13,4.96 a2.06,2.06 0 0,1 2.06,-2.06 H20.82 a2.06,2.06 0 0,1 2.06,2.06"
             " V8.72 H1.13 Z", A_BAND, None),
    ("fill", rrect(5.3, 1.03, 1.5, 4.97, 0.75), A_RING, None),
    ("fill", rrect(9.38, 1.03, 1.5, 4.97, 0.75), A_RING, None),
    ("fill", rrect(13.46, 1.03, 1.5, 4.97, 0.75), A_RING, None),
    ("fill", rrect(17.34, 1.03, 1.5, 4.97, 0.75), A_RING, None),
    ("stroke", "M8.2,14.9 L11.16,17.25 L15.66,12.56", A_CHECK, 2.06),
]

# ── 주사위 굴리기 ─────────────────────────────────────────────────────────
# 앞뒤 주사위가 **다른 결**을 쓴다 — 같은 결이면 겹친 자리에서 두 개가 한 덩어리로 붙는다
DICE_BACK_G = {"x1": 1.8, "y1": 2.9, "x2": 13.1, "y2": 14.1,
               "stops": [(0, "#F9C800"), (1, "#F0A000")]}
DICE_FRONT_G = {"x1": 11.25, "y1": 9.6, "x2": 22.15, "y2": 20.8,
                "stops": [(0, "#F5B300"), (1, "#E88600")]}
DICE_PIP = "#FFFFFF"

DICE = [
    ("fill", rrect(1.8, 2.9, 11.3, 11.2, 2.25), DICE_BACK_G, None),
    ("fill", circ(9.6, 6.6, 1.03), DICE_PIP, None),
    ("fill", circ(5.2, 10.5, 1.03), DICE_PIP, None),
    ("fill", rrect(11.25, 9.6, 10.9, 11.2, 2.25), DICE_FRONT_G, None),
] + [("fill", circ(cx, cy, 0.89), DICE_PIP, None)
     for cx in (13.7, 19.3) for cy in (12.7, 15.2, 17.8)]

# ── 식단 (수저) ───────────────────────────────────────────────────────────
U_METAL = "#CBD5DE"
U_BAND = "#F0AC63"
U_GRIP = "#E4636F"

UTENSIL = [
    # 숟가락 — 볼 + 잘록한 목
    ("fill", ellipse(6.6, 6.1, 3.66, 4.69), U_METAL, None),
    ("fill", "M5.6,9.5 C5.6,11.4 5.2,12.2 5.2,13.6 H7.9 C7.9,12.2 7.5,11.4 7.5,9.5 Z",
     U_METAL, None),
    ("fill", rrect(4.13, 13.5, 4.78, 1.75, 0.2), U_BAND, None),
    ("fill", "M4.13,15.25 H8.91 V20.11 a2.39,2.39 0 0,1 -4.78,0 Z", U_GRIP, None),
    # 포크 — 살 셋이 밑에서 모여 목이 된다
    ("fill", rrect(12.57, 1.5, 1.5, 7.2, 0.75), U_METAL, None),
    ("fill", rrect(15.95, 1.5, 1.5, 7.2, 0.75), U_METAL, None),
    ("fill", rrect(19.33, 1.5, 1.5, 7.2, 0.75), U_METAL, None),
    ("fill", "M12.57,7 H20.83 C20.83,9.6 17.7,9.8 17.7,11.4 V13.6 H15.7 V11.4"
             " C15.7,9.8 12.57,9.6 12.57,7 Z", U_METAL, None),
    ("fill", rrect(14.31, 13.5, 4.78, 1.75, 0.2), U_BAND, None),
    ("fill", "M14.31,15.25 H19.09 V20.11 a2.39,2.39 0 0,1 -4.78,0 Z", U_GRIP, None),
]

# ── 카드 긁기 ─────────────────────────────────────────────────────────────
# 카드는 **좌우가 다른 빨강**이다. 통짜로 칠하면 납작한 판때기로 보인다
C_LEFT = "#FF6242"
C_RIGHT = "#FF2D00"
C_MAG_L = "#75757E"
C_MAG_R = "#5A5A63"
C_LINE = "#EFEAE1"
C_CHIP = "#FF9500"

SCRATCH = [
    ("fill", rrect(0.4, 3.85, 23.2, 16.4, 1.5), C_LEFT, None),
    ("fill", "M12,3.85 H22.1 a1.5,1.5 0 0,1 1.5,1.5 V18.75 a1.5,1.5 0 0,1 -1.5,1.5 H12 Z",
     C_RIGHT, None),
    ("fill", "M0.4,6.85 H12 V9.95 H0.4 Z", C_MAG_L, None),      # 자기 띠
    ("fill", "M12,6.85 H23.6 V9.95 H12 Z", C_MAG_R, None),
    ("fill", rrect(2.58, 13.65, 3.38, 1.22, 0.61), C_LINE, None),
    ("fill", rrect(2.58, 16.32, 4.92, 1.22, 0.61), C_LINE, None),
    ("fill", rrect(15.48, 13.27, 6, 4.41, 0.75), C_CHIP, None),  # 칩
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
    """조각은 `(kind, path, color, width)` 또는 회전을 붙인 `(..., degrees)` 다.

    회전은 **그룹으로 감싼다** — 호가 섞인 path 를 좌표로 돌려 쓰려면 명령을 전부 다시 써야 한다.
    """
    android, svg, defs, aapt = "", "", "", False
    for idx, part in enumerate(parts):
        kind, d, color, w = part[:4]
        rot = part[4] if len(part) > 4 else 0
        if isinstance(color, dict):
            # 결(그라디언트) — Android 는 aapt 속성, SVG 는 defs. 좌표계는 둘 다 24 기준이다
            aapt = True
            gid = f"g{idx}"
            items = "".join(
                f'                <item android:offset="{o}" android:color="{c}" />\n'
                for o, c in color["stops"])
            body_a = (f'    <path\n        android:pathData="{d}">\n'
                      f'        <aapt:attr name="android:fillColor">\n'
                      f'            <gradient\n'
                      f'                android:type="linear"\n'
                      f'                android:startX="{color["x1"]}"\n'
                      f'                android:startY="{color["y1"]}"\n'
                      f'                android:endX="{color["x2"]}"\n'
                      f'                android:endY="{color["y2"]}">\n'
                      f'{items}'
                      f'            </gradient>\n'
                      f'        </aapt:attr>\n'
                      f'    </path>\n')
            stops = "".join(f'      <stop offset="{o}" stop-color="{c}"/>\n'
                            for o, c in color["stops"])
            defs += (f'    <linearGradient id="{gid}" x1="{color["x1"]}" y1="{color["y1"]}"'
                     f' x2="{color["x2"]}" y2="{color["y2"]}" gradientUnits="userSpaceOnUse">\n'
                     f'{stops}    </linearGradient>\n')
            body_s = f'  <path d="{d}" fill="url(#{gid})"'
            android += body_a
            svg += body_s + '/>\n'
            continue
        if kind == "fill":
            body_a = (f'    <path\n        android:pathData="{d}"\n'
                      f'        android:fillColor="{color}" />\n')
            body_s = f'  <path d="{d}" fill="{color}"'
        else:
            body_a = (f'    <path\n        android:pathData="{d}"\n'
                      f'        android:strokeWidth="{w}"\n'
                      f'        android:strokeColor="{color}"\n'
                      f'        android:strokeLineCap="round"\n'
                      f'        android:strokeLineJoin="round" />\n')
            body_s = (f'  <path d="{d}" fill="none" stroke="{color}" stroke-width="{w}"'
                      ' stroke-linecap="round" stroke-linejoin="round"')
        if rot:
            android += (f'    <group android:rotation="{rot}"'
                        f' android:pivotX="12" android:pivotY="12">\n'
                        + body_a.replace("    <path", "        <path")
                                .replace("        android:", "            android:")
                        + '    </group>\n')
            svg += body_s + f' transform="rotate({rot} 12 12)"/>\n'
        else:
            android += body_a
            svg += body_s + '/>\n'
    if defs:
        svg = f'  <defs>\n{defs}  </defs>\n' + svg
    write(name, android, svg, aapt=aapt)


# 웨이트 · 유산소는 **행에서만** 원색이다 — 활동 랜딩은 아직 두 톤 벌(`ic_benefit_*`)을 쓴다.
# 그래서 이름을 덮지 않고 `_color` 로 따로 둔다
bake("ic_benefit_routine_color", WEIGHT)
bake("ic_benefit_cardio_color", CARDIO)
bake("ic_benefit_scale_color", SCALE)
bake("ic_benefit_water_color", WATER)
bake("ic_benefit_luck_color", CLOVER)
bake("ic_benefit_stretch_color", MAT)
bake("ic_benefit_touch_color", TOUCH)
bake("ic_benefit_attend_color", ATTEND)
bake("ic_benefit_dice_color", DICE)
bake("ic_benefit_diet_color", UTENSIL)
bake("ic_benefit_scratch_color", SCRATCH)

print("wrote 13 color icons")
