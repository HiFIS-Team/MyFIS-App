"""지점 안에서 **찾아갈 구역**(`ic_place_*`) 중 **단색 아웃라인 벌**을 굽는다.

    python3 tools/icons/gen_place_icons.py

M-08 `기구 찾기` 맨 위의 빠른 고르기 판에 들어간다 (DESIGN §6.26).

§8 규칙 그대로 **아웃라인 · 24×24** 이고, 굵기만 **2.0** 이다 —
탭(1.5)보다 굵은 건 `28` 판 안에 놓이기 때문이다. 1.5 로 그리면 판 안에서 가늘게 뜬다.

⚠️ 여덟 칸 중 여기서 굽는 건 **샤워실 하나뿐**이다. 나머지 일곱은 원본이 원색이라 다른 데서 온다 —
프리웨이트 · 유산소 · 스트레칭은 `gen_color_icons.py`(혜택 행과 **같은 그림**),
머신 · 데스크 · 화장실 · 탈의실은 `gen_place_color_icons.py`.
"""
import os, json

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"

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

ICONS = {
    "ic_place_shower": SHOWER,
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
