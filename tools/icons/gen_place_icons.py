"""지점 안에서 **찾아갈 곳**(`ic_place_*`)을 두 플랫폼에 한 번에 굽는다.

    python3 tools/icons/gen_place_icons.py

M-08 `기구 찾기` 맨 위의 빠른 고르기 판에 들어간다 (DESIGN §6.26).

§8 규칙 그대로 **아웃라인 · 24×24** 이고, 굵기만 **2.0** 이다 —
탭(1.5)보다 굵은 건 `28` 판 안에 놓이기 때문이다. 1.5 로 그리면 판 안에서 가늘게 뜬다.

⚠️ 원색 벌이 아니다. 여덟이 **한 줄의 고르기**라 색이 붙으면 그 칸만 먼저 읽힌다 (§3.2).
"""
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"

# ── 기구 ────────────────────────────────────────────────────────────────────
# 스쿼트랙 — 기둥 둘 + 걸린 바. **바가 기둥을 뚫고 나와야** 랙으로 읽힌다
RACK = " ".join([
    "M6.5,4 v15",               # 왼쪽 기둥
    "M17.5,4 v15",              # 오른쪽 기둥
    "M3.5,8.5 h17",             # 바 — 기둥 밖으로 나온다
    "M4.2,6.6 v3.8",            # 왼쪽 원판
    "M19.8,6.6 v3.8",           # 오른쪽 원판
    "M4.5,19 h4",               # 발
    "M15.5,19 h4",
])

# 벤치 — 등판 + **벌어진 다리**. 다리를 수직으로 세우면 탁자로 읽힌다
BENCH = " ".join([
    "M4,9.5 h16",               # 등판 윗면
    "M4,12 h16",                # 등판 아랫면 — 두께가 있어야 방석이 된다
    "M4,9.5 v2.5",              # 왼쪽 마구리
    "M20,9.5 v2.5",             # 오른쪽 마구리
    "M7,12 L5,19",              # 왼쪽 다리
    "M7,12 L9,19",
    "M17,12 L15,19",            # 오른쪽 다리
    "M17,12 L19,19",
])

# 덤벨 — 원판이 **안쪽 · 바깥쪽 둘**이라야 손잡이가 짧아 보인다
DUMBBELL = " ".join([
    "M4.5,10 v4",               # 왼쪽 바깥 원판
    "M8,7.5 v9",                # 왼쪽 안쪽 원판
    "M8,12 h8",                 # 손잡이
    "M16,7.5 v9",               # 오른쪽 안쪽 원판
    "M19.5,10 v4",              # 오른쪽 바깥 원판
])

# 러닝머신 — 탭(`ic_tab_cardio`)은 바닥이 **선 하나**였는데, 여기선 **사다리꼴 몸통**이다.
# 판 안에 홀로 놓이면 선 하나짜리 바닥이 속도선과 섞여 깃대처럼 읽힌다
TREADMILL = " ".join([
    "M3.2,16.4 h11.2",          # 벨트 윗면
    "M4.4,19.2 h12",            # 받침
    "M3.2,16.4 L4.4,19.2",      # 왼쪽 마구리
    "M14.4,16.4 L16.4,19.2",    # 오른쪽 마구리 — 사다리꼴이라야 기계 몸통이 된다
    "M14.4,16.4 L17.8,7.8",     # 기둥
    "M14.2,6.4 h6.2",           # 손잡이
    "M14.2,6.4 v1.8",           # 손잡이 끝 꺾임
    "M3.4,9.4 h5",              # 속도선 — 길이를 어긋나게 둔다
    "M5,12.4 h4",
])

# ── 편의시설 ────────────────────────────────────────────────────────────────
# ⚠️ 화장실 · 탈의실은 여기 없다 — **원색 벌**이라 `gen_place_color_icons.py` 에서 굽는다
# 샤워실 — 헤드는 **사다리꼴**이다. 돔으로 그리면 전등으로 읽힌다.
# 물줄기는 **길이를 어긋나게** 둔다. 나란히 맞추면 울타리가 된다
SHOWER = " ".join([
    "M12,3 v2.8",               # 파이프
    "M9.2,5.8 h5.6",            # 헤드 윗면
    "M7,9.2 h10",               # 헤드 아랫면 — 위보다 넓다
    "M9.2,5.8 L7,9.2",
    "M14.8,5.8 L17,9.2",
    "M8.8,11.8 v1.8",           # 물줄기
    "M12,12.4 v2.4",
    "M15.2,11.8 v1.8",
    "M10.2,16.6 v1.6",
    "M13.8,16.4 v1.8",
])

# PT존 — 사람 + **덤벨 한 짝**. 사람만 두면 화장실과 갈라지지 않는다
PT = " ".join([
    "M9.6,7.6 m-2.6,0 a2.6,2.6 0 1 0 5.2,0 a2.6,2.6 0 1 0 -5.2,0",  # 머리
    "M4,19 a5.6,5.6 0 0 1 11.2,0",   # 어깨
    "M17.2,4.9 v5.2",           # 덤벨 안쪽 원판 — 작으면 열쇠로 읽힌다
    "M20.8,6.3 v2.4",           # 덤벨 바깥 원판
    "M17.2,7.5 h3.6",           # 손잡이
])

ICONS = {
    "ic_place_rack": RACK,
    "ic_place_bench": BENCH,
    "ic_place_dumbbell": DUMBBELL,
    "ic_place_treadmill": TREADMILL,
    "ic_place_shower": SHOWER,
    "ic_place_pt": PT,
}

STROKE = "2"

ANDROID_TPL = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
    <path
        android:pathData="{d}"
        android:strokeWidth="{w}"
        android:strokeColor="#FFFFFF"
        android:strokeLineCap="round"
        android:strokeLineJoin="round" />
</vector>
"""

SVG_TPL = ('<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24">\n'
           '  <path d="{d}" fill="none" stroke="#000000" stroke-width="{w}"'
           ' stroke-linecap="round" stroke-linejoin="round"/>\n'
           '</svg>\n')

for name, d in ICONS.items():
    open(f"{ANDROID}/{name}.xml", "w").write(ANDROID_TPL.format(d=d, w=STROKE))
    folder = f"{IOS}/{name}.imageset"
    os.makedirs(folder, exist_ok=True)
    open(f"{folder}/{name}.svg", "w").write(SVG_TPL.format(d=d, w=STROKE))
    open(f"{folder}/Contents.json", "w").write(json.dumps({
        "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": True,
                       "template-rendering-intent": "template"},
    }, indent=2) + "\n")

print("wrote", len(ICONS), "icons")
