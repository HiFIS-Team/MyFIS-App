"""하단 탭 아이콘(`ic_tab_*`) 중 **웨이트 · 유산소**를 두 플랫폼에 한 번에 굽는다.

    python3 tools/icons/gen_tab_icons.py

탭 아이콘은 §8 규칙대로 **아웃라인 1.5 / 24×24** 이고,
선택 상태(`_fill`)는 같은 길을 **굵게**(2.2) 그린 것이다 — 다른 탭과 같은 방식.
"""
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"

# 웨이트 — **벤치프레스 랙** (사용자 제공 그림).
# 24px 짜리 탭 아이콘이라 원본에서 **발 세 짝을 뺐다** — 넣으면 아래가 뭉친다.
WEIGHT = " ".join([
    "M4,5 v6",                  # 왼쪽 원판 — 바보다 위아래로 길어야 원판으로 읽힌다
    "M20,5 v6",                 # 오른쪽 원판
    "M4,8 h16",                 # 바
    "M7.5,6.5 v13",             # 왼쪽 기둥
    "M16.5,6.5 v13",            # 오른쪽 기둥
    "M10,14 h4",                # 벤치 등판
    "M12,14 v5",                # 벤치 다리
])

# 유산소 — **러닝머신** (사용자 제공 그림).
# 바닥은 **선 하나**다. 네모로 그리면 24px 에서 속이 메워진다.
CARDIO = " ".join([
    "M3,9.6 h6",                # 속도선 — 길이·자리를 어긋나게 둬야 흐르는 느낌이 난다
    "M4.8,12.4 h5.4",
    "M11.2,6.6 h7",             # 손잡이
    "M11.2,6.6 v1.6",           # 손잡이 끝 꺾임
    "M17.6,7 L16.2,17",         # 기둥
    "M2.6,17 h18.8",            # 달리는 바닥
    "M6,17 v2.4",               # 발
    "M17,17 v2.4",
])

ICONS = {"ic_tab_weight": WEIGHT, "ic_tab_cardio": CARDIO}

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
    # 굵은 벌은 **2.2** 다 — 다른 탭(2.6~2.8)보다 얇다. 획이 많아 그보다 굵으면 덩어리가 된다
    for suffix, w in (("", "1.5"), ("_fill", "2.2")):
        full = name + suffix
        open(f"{ANDROID}/{full}.xml", "w").write(ANDROID_TPL.format(d=d, w=w))
        folder = f"{IOS}/{full}.imageset"
        os.makedirs(folder, exist_ok=True)
        open(f"{folder}/{full}.svg", "w").write(SVG_TPL.format(d=d, w=w))
        open(f"{folder}/Contents.json", "w").write(json.dumps({
            "images": [{"filename": f"{full}.svg", "idiom": "universal"}],
            "info": {"author": "xcode", "version": 1},
            "properties": {"preserves-vector-representation": True,
                           "template-rendering-intent": "template"},
        }, indent=2) + "\n")

print("wrote", len(ICONS) * 2, "icons")
