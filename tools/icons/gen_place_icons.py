"""지점 안에서 **찾아갈 구역**(`ic_place_*`) 중 **단색 아웃라인 벌**을 굽는다.

    python3 tools/icons/gen_place_icons.py

M-08 `기구 찾기` 맨 위의 빠른 고르기 판에 들어간다 (DESIGN §6.26).

§8 규칙 그대로 **아웃라인 · 24×24** 이고, 굵기만 **2.0** 이다 —
탭(1.5)보다 굵은 건 `28` 판 안에 놓이기 때문이다. 1.5 로 그리면 판 안에서 가늘게 뜬다.

⚠️ 여덟 칸 중 여기서 굽는 건 **셋뿐**이다. 나머지는 원본이 원색이라 다른 데서 온다 —
프리웨이트 · 유산소 · 스트레칭은 `gen_color_icons.py`(혜택 행과 **같은 그림**),
화장실 · 탈의실은 `gen_place_color_icons.py`.
"""
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"

# 머신 — 왼쪽은 **의자**, 오른쪽은 **중량 스택**. 두 덩어리로 갈라야 28px 에서 잡힌다.
# ⚠️ 랫풀다운처럼 윗대 · 케이블 · 바까지 그렸더니 **선이 열한 개**가 되어 얼룩이 됐다.
# ⚠️ 스택은 상자 안을 **셋으로만** 나눈다. 넷으로 나누면 칸 사이가 굵기보다 좁아진다
MACHINE = " ".join([
    "M3.8,13.6 h7.8 v2.4 h-7.8 z",   # 좌판 — 두께가 있어야 방석이 된다 (벤치와 같은 어법)
    "M11.6,13.6 v-7.6",              # 등받이
    "M7.4,16 v2.8",                  # 기둥
    "M5.6,18.8 h3.6",                # 발
    "M14.6,5.8 h5.8 v11.6 h-5.8 z",  # 스택 상자
    "M14.6,9.7 h5.8",                # 중량 판 가름선
    "M14.6,13.6 h5.8",
])

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

# 데스크 — **사람 + 카운터**. 카운터만 그리면 책상이고, 사람만 그리면 트레이너다.
# ⚠️ 카운터를 네모로 그리면 침대로 읽힌다 — **아래로 벌어지는 사다리꼴**이라야 데스크가 된다
DESK = " ".join([
    "M12,6 m-2.3,0 a2.3,2.3 0 1 0 4.6,0 a2.3,2.3 0 1 0 -4.6,0",  # 머리
    "M8.5,13.2 a3.5,3.5 0 0 1 7,0",     # 어깨 — 카운터 윗선에 닿는다
    "M2.4,13.2 h19.2",          # 카운터 윗선 — 사람보다 넓어야 카운터가 된다
    "M4.2,13.2 L3,19.4",        # 앞판 — 벌어진다
    "M19.8,13.2 L21,19.4",
    "M3,19.4 h18",
])

ICONS = {
    "ic_place_machine": MACHINE,
    "ic_place_shower": SHOWER,
    "ic_place_desk": DESK,
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
