"""혜택 행 아이콘(`ic_benefit_*`)을 안드로이드 · iOS 양쪽에 한 번에 굽는다.

    python3 tools/icons/gen_benefit_icons.py

두 벌을 손으로 관리하면 반드시 어긋난다 — **여기만 고치고 다시 굽는다.**
그리는 규칙은 DESIGN.md §8 (채움 두 톤 · 28px 에서 뭘로 읽히는지) 참고.
"""
# 한 아이콘 = 조각 목록. 조각은 (path, light) — light 면 알파 40%.
# 겹치는 조각은 **따로 <path> 로 낸다** (한 path 안에서 겹치면 winding 이 서로 깎는다).
import os, json, math

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ANDROID = f"{ROOT}/androidApp/src/main/res/drawable"
IOS = f"{ROOT}/iosApp/iosApp/Assets.xcassets"

def n(v):
    return f"{round(v, 2):g}"

def rrect(x, y, w, h, r):
    """둥근 사각"""
    return (f"M{n(x+r)},{n(y)} h{n(w-2*r)} a{n(r)},{n(r)} 0 0,1 {n(r)},{n(r)}"
            f" v{n(h-2*r)} a{n(r)},{n(r)} 0 0,1 {n(-r)},{n(r)} h{n(-(w-2*r))}"
            f" a{n(r)},{n(r)} 0 0,1 {n(-r)},{n(-r)} v{n(-(h-2*r))}"
            f" a{n(r)},{n(r)} 0 0,1 {n(r)},{n(-r)} Z")

def circ(cx, cy, r):
    return (f"M{n(cx-r)},{n(cy)} a{n(r)},{n(r)} 0 1,1 {n(2*r)},0"
            f" a{n(r)},{n(r)} 0 1,1 {n(-2*r)},0 Z")

def dome(cx, cy, r):
    """위쪽 반원 (평평한 변이 아래)"""
    return f"M{n(cx-r)},{n(cy)} a{n(r)},{n(r)} 0 0,1 {n(2*r)},0 Z"

def stroke(points, w):
    """두꺼운 꺾은선 — 마디마다 사각 하나 + 이음새 원. 조각을 따로 내야 안 깎인다"""
    out, h = [], w / 2
    for (x1, y1), (x2, y2) in zip(points, points[1:]):
        dx, dy = x2 - x1, y2 - y1
        L = math.hypot(dx, dy)
        ox, oy = -dy / L * h, dx / L * h
        out.append(f"M{n(x1+ox)},{n(y1+oy)} L{n(x2+ox)},{n(y2+oy)}"
                   f" L{n(x2-ox)},{n(y2-oy)} L{n(x1-ox)},{n(y1-oy)} Z")
    for x, y in points[1:-1]:
        out.append(circ(x, y, h))
    return out

HEART = ("M12,21.2 l-1.4,-1.3 C5.5,15.2 2.2,12.2 2.2,8.5 C2.2,5.5 4.6,3.1 7.6,3.1"
         " c1.7,0 3.3,0.8 4.4,2.1 C13.1,3.9 14.7,3.1 16.4,3.1 C19.4,3.1 21.8,5.5 21.8,8.5"
         " c0,3.7 -3.3,6.7 -8.4,11.4 L12,21.2 Z")

ICONS = {
    # 덤벨 — 봉이 가늘어 목록에서 사라졌다. 원판을 키우고 봉을 옅은 톤으로 내린다
    "ic_benefit_routine": (
        [(rrect(8.4, 10.6, 7.2, 2.8, 1.4), True),
         (rrect(2.2, 9.4, 2.2, 5.2, 1.1), True),
         (rrect(19.6, 9.4, 2.2, 5.2, 1.1), True),
         (rrect(4.4, 6.6, 4.4, 10.8, 2), False),
         (rrect(15.2, 6.6, 4.4, 10.8, 2), False)], None),

    # 유산소 — 불꽃은 몇 번을 고쳐도 물방울로 읽혔다. **심박**으로 바꾼다
    "ic_benefit_cardio": (
        [(HEART, True)]
        + [(p, False) for p in stroke(
            [(4.8, 11.5), (8.8, 11.5), (10.3, 8.4), (13.2, 15), (14.6, 11.5), (19.2, 11.5)], 2.3)],
        None),

    # 스트레칭 — 1.5 짜리 막대 인간이라 판 안에서 사라졌다. 팔다리를 굵게
    "ic_benefit_stretch": (
        [("M10.2,10.6 l1.5,-2.4 -5.6,-3.5 -1.5,2.4 Z", True),
         ("M13.8,10.6 l-1.5,-2.4 5.6,-3.5 1.5,2.4 Z", True),
         (circ(12, 4.4, 2.7), False),
         (rrect(10.4, 7.6, 3.2, 6.8, 1.6), False),
         ("M9.9,13.4 h2.9 l-2.2,7.6 h-2.9 Z", False),
         ("M11.2,13.4 h2.9 l2.2,7.6 h-2.9 Z", False)], None),

    # 도장 — 넓어지는 3단이라 케이크로 읽혔다. 손잡이 + 목 + 밑판 + 찍힌 자국으로
    "ic_benefit_stamp": (
        [(rrect(3.4, 18.4, 17.2, 2.8, 1.4), True),
         (rrect(9.2, 2.8, 5.6, 4.8, 2.4), False),
         ("M10.2,7.2 h3.6 l1.7,5.4 h-7 Z", False),
         (rrect(5.2, 12.4, 13.6, 3.4, 1.2), False)], None),

    # 사다리 — 기둥이 붙어 있어 `H` 로 읽혔다. 폭을 벌리고 발판을 길게
    "ic_benefit_ladder": (
        [(rrect(5.6, 6.4, 12.8, 2.6, 1.3), True),
         (rrect(5.6, 10.7, 12.8, 2.6, 1.3), True),
         (rrect(5.6, 15, 12.8, 2.6, 1.3), True),
         (rrect(4, 2.6, 3.2, 18.8, 1.6), False),
         (rrect(16.8, 2.6, 3.2, 18.8, 1.6), False)], None),

    # 뽑기 — 반으로 가른 공은 반달, 돔+통은 자물쇠, 유리구+알맹이는 해골로 읽혔다.
    # 결국 **공 + 가운데 띠 + 버튼 구멍** — 뽑기 캡슐 그대로가 제일 잘 읽힌다
    "ic_benefit_luck": (
        [(circ(12, 12, 8.4), True),
         (rrect(4.4, 10.6, 15.2, 2.8, 1.4) + " " + circ(12, 12, 1.25), False)], "evenodd"),

    # 체중계 — 발판 둘 + 표시창이 얼굴로 읽혔다. 눈금판 하나만 남긴다
    "ic_benefit_scale": (
        [(rrect(2.6, 4.6, 18.8, 14.8, 3.2), True),
         (circ(12, 12, 5.2) + " " + circ(12, 12, 3.4) + " M11.1,12 l0.9,-4.4 0.9,4.4 Z", False)],
        "evenodd"),

    # 인스타 · 퀴즈는 **원색 벌**이라 여기 없다 → tools/icons/gen_color_icons.py
}

ANDROID_TPL = """<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp"
    android:height="24dp"
    android:viewportWidth="24"
    android:viewportHeight="24">
{paths}
</vector>
"""

for name, (parts, rule) in ICONS.items():
    chunks = []
    for d, light in parts:
        line = f'    <path\n        android:pathData="{d}"\n        android:fillColor="#FFFFFF"'
        if rule and d.count("M") > 1:
            # Android 는 `evenOdd`, SVG 는 `evenodd` — 철자가 다르다
            line += f'\n        android:fillType="evenOdd"'
        if light:
            line += '\n        android:fillAlpha="0.4"'
        chunks.append(line + ' />')
    open(f"{ANDROID}/{name}.xml", "w").write(ANDROID_TPL.format(paths="\n".join(chunks)))

    lines = ['<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">']
    for d, light in parts:
        attrs = ' fill="#000000"'
        if rule and d.count("M") > 1:
            attrs += f' fill-rule="{rule}"'
        if light:
            attrs += ' fill-opacity="0.4"'
        lines.append(f'  <path d="{d}"{attrs}/>')
    lines.append('</svg>')
    d = f"{IOS}/{name}.imageset"
    os.makedirs(d, exist_ok=True)
    open(f"{d}/{name}.svg", "w").write("\n".join(lines) + "\n")
    open(f"{d}/Contents.json", "w").write(json.dumps({
        "images": [{"filename": f"{name}.svg", "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": True,
                       "template-rendering-intent": "template"},
    }, indent=2) + "\n")

print("wrote", len(ICONS), "icons")
