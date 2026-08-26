"""앱 아이콘 한 벌을 **원본 하나에서** 굽는다 (DESIGN.md §8.1).

    python3 tools/icons/gen_app_icon.py [원본.png]

원본은 `assets/brand/logo.png` — 검정 배경에 라임→옐로 FS 마크다.
**원본의 여백 비율을 그대로 쓴다.** 마크만 떼어 다시 앉히면 원본과 다른 아이콘이 된다.
"""
import os
import sys
from PIL import Image, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC = sys.argv[1] if len(sys.argv) > 1 else f"{ROOT}/assets/brand/logo.png"

ANDROID = f"{ROOT}/androidApp/src/main/res"
IOS_ICON = f"{ROOT}/iosApp/iosApp/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

# 런처 아이콘 밀도별 크기 — 레거시(48dp) / 어댑티브 레이어(108dp)
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def extract(src):
    """검정 배경 위 그림에서 **밝기를 알파로** 떼어낸다.

    배경이 순검정이라 픽셀값이 이미 `색 × 알파` 다. 알파로 나눠 **색을 되돌려야**
    가장자리가 거뭇하게 남지 않는다.
    """
    im = src.convert("RGB")
    r, g, b = im.split()
    alpha = ImageChops.lighter(ImageChops.lighter(r, g), b)
    px, ap = im.load(), alpha.load()
    out = Image.new("RGBA", im.size)
    op = out.load()
    for y in range(im.size[1]):
        for x in range(im.size[0]):
            a = ap[x, y]
            if a == 0:
                continue
            cr, cg, cb = px[x, y]
            k = 255 / a
            op[x, y] = (min(255, int(cr * k)), min(255, int(cg * k)), min(255, int(cb * k)), a)
    return out


def circle_mask(size):
    # 4배로 그리고 줄여서 계단을 없앤다
    m = Image.new("L", (size * 4, size * 4), 0)
    from PIL import ImageDraw
    ImageDraw.Draw(m).ellipse((0, 0, size * 4 - 1, size * 4 - 1), fill=255)
    return m.resize((size, size), Image.LANCZOS)


def main():
    src = Image.open(SRC)
    mark = extract(src)

    # ── iOS — 1024 **불투명**. iOS 는 알파를 못 쓴다
    flat = Image.new("RGB", src.size, (0, 0, 0))
    flat.paste(mark, (0, 0), mark)
    flat.resize((1024, 1024), Image.LANCZOS).save(IOS_ICON)

    # ── Android
    white = Image.new("RGBA", src.size, (255, 255, 255, 255))
    white.putalpha(mark.getchannel("A"))

    for name, scale in DENSITIES.items():
        d = f"{ANDROID}/mipmap-{name}"
        os.makedirs(d, exist_ok=True)
        legacy, layer = int(48 * scale), int(108 * scale)

        # 어댑티브 레이어 — 배경은 `@color/ic_launcher_background` 가 따로 깐다
        mark.resize((layer, layer), Image.LANCZOS).save(f"{d}/ic_launcher_foreground.png")
        white.resize((layer, layer), Image.LANCZOS).save(f"{d}/ic_launcher_monochrome.png")

        # 레거시(API 25 이하) — 배경까지 그려 넣는다
        sq = flat.resize((legacy, legacy), Image.LANCZOS).convert("RGBA")
        sq.save(f"{d}/ic_launcher.png")
        rnd = sq.copy()
        rnd.putalpha(circle_mask(legacy))
        rnd.save(f"{d}/ic_launcher_round.png")

    # ── 브랜드 원본 옆에 **배경 뺀 벌**도 같이 둔다 (마크만 필요한 곳용)
    mark.crop(mark.getbbox()).save(f"{ROOT}/assets/brand/logo-mark.png")

    box = src.convert("L").point(lambda v: 255 if v > 30 else 0).getbbox()
    print("구웠다 — 마크가 캔버스의 %.0f%% (원본 비율 그대로)" % ((box[2] - box[0]) / src.size[0] * 100))


main()
