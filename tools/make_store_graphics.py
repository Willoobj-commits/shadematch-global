#!/usr/bin/env python3
"""Generate Play Store graphics and Android launcher icons.

Colours are not invented: profile_sample_color() is a direct port of
lib/core/services/profile_color.dart, so every swatch drawn here is a colour
the app itself would generate for that depth and undertone. The brand plum
matches the seed colour in lib/app.dart.

    python tools/make_store_graphics.py            # store graphics only
    python tools/make_store_graphics.py --launcher # also rewrite mipmaps

Outputs land in store_assets/. Screenshots are captured separately - Play
requires those to show the real running app.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

# --- brand -----------------------------------------------------------------

PLUM = (0x61, 0x24, 0x5B)          # lib/app.dart seedColor
GROUND_TOP = (0x4A, 0x1A, 0x44)
GROUND_BOTTOM = (0x27, 0x0D, 0x27)
CREAM = (0xFF, 0xF9, 0xF7)         # scaffoldBackgroundColor
MUTED = (0xC9, 0xA8, 0xC2)

SS = 4  # supersample factor; everything is drawn large and downscaled

FONT_DIR = Path(__file__).resolve().parent / "fonts"
DISPLAY_FONT = "ClashDisplay-Semibold.ttf"
BODY_FONT = "GeneralSans-Medium.ttf"


# --- colour engine (port of profile_color.dart) ----------------------------

ADJUSTMENTS = {
    "N": (0, 0), "C": (3, -4), "W": (1, 5), "G": (0.5, 6), "CP": (6, -5),
    "CR": (7, -1), "CB": (4, -7), "WY": (0, 8), "WG": (1, 7), "WP": (4, 4),
    "PCH": (5, 2), "NP": (3, 1), "NG": (0, 3), "NR": (5, 0), "WN": (0.5, 2.5),
    "CN": (1.5, -2), "O": (-3, 1), "ON": (-2, 0.5), "OY": (-2, 4),
    "OG": (-3, 3), "U": (0, 0),
}


def profile_sample_color(depth: int, undertone: str = "N") -> tuple[int, int, int]:
    fraction = (max(1, min(30, depth)) - 1) / 29
    da, db = ADJUSTMENTS.get(undertone, ADJUSTMENTS["U"])
    lightness = 94 - fraction * 72
    a_value = 7 + fraction * 7 + da
    b_value = 13 + fraction * 9 + db
    return _lab_to_rgb(lightness, a_value, b_value)


def _lab_to_rgb(lightness: float, a_value: float, b_value: float) -> tuple[int, int, int]:
    fy = (lightness + 16) / 116
    fx = a_value / 500 + fy
    fz = fy - b_value / 200

    def pivot_inverse(value: float) -> float:
        cube = value ** 3
        return cube if cube > 0.008856 else (value - 16 / 116) / 7.787

    x = 0.95047 * pivot_inverse(fx)
    y = pivot_inverse(fy)
    z = 1.08883 * pivot_inverse(fz)
    linear = (
        x * 3.2404542 + y * -1.5371385 + z * -0.4985314,
        x * -0.9692660 + y * 1.8760108 + z * 0.0415560,
        x * 0.0556434 + y * -0.2040259 + z * 1.0572252,
    )

    def gamma(value: float) -> int:
        transformed = 12.92 * value if value <= 0.0031308 else 1.055 * (value ** (1 / 2.4)) - 0.055
        return max(0, min(255, round(transformed * 255)))

    return tuple(gamma(channel) for channel in linear)


# --- drawing helpers -------------------------------------------------------

def vertical_gradient(size: tuple[int, int], top: tuple, bottom: tuple) -> Image.Image:
    width, height = size
    image = Image.new("RGB", (1, height))
    pixels = image.load()
    for y in range(height):
        t = y / max(1, height - 1)
        pixels[0, y] = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
    return image.resize((width, height), Image.BILINEAR)


def load_font(name: str, size: int) -> ImageFont.FreeTypeFont:
    path = FONT_DIR / name
    if not path.is_file():
        raise SystemExit(f"error: font missing at {path}\nrun tools/fetch_fonts.py or copy the .ttf there")
    return ImageFont.truetype(str(path), size)


def draw_shade_ring(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], segments: int, width: int) -> None:
    """A thick ring of real shade chips, light at the top, deepening clockwise."""
    gap = 2.4  # degrees of ground showing between chips
    span = 360 / segments
    for index in range(segments):
        depth = round(4 + (index / (segments - 1)) * 22)
        colour = profile_sample_color(depth, "N")
        start = -90 + index * span + gap / 2
        end = start + span - gap
        draw.arc(box, start, end, fill=colour, width=width)


# --- store icon ------------------------------------------------------------

def build_icon(size: int = 512) -> Image.Image:
    side = size * SS
    canvas = vertical_gradient((side, side), GROUND_TOP, GROUND_BOTTOM)
    draw = ImageDraw.Draw(canvas)

    margin = side * 0.155
    ring_box = (margin, margin, side - margin, side - margin)
    draw_shade_ring(draw, ring_box, segments=9, width=round(side * 0.115))

    # the matched shade, sitting in the middle of the range the ring covers
    centre = side / 2
    dot = side * 0.148
    draw.ellipse(
        (centre - dot, centre - dot, centre + dot, centre + dot),
        fill=profile_sample_color(15, "N"),
    )

    return canvas.resize((size, size), Image.LANCZOS)


# --- feature graphic -------------------------------------------------------

def build_feature_graphic(width: int = 1024, height: int = 500) -> Image.Image:
    canvas = vertical_gradient((width * SS, height * SS), GROUND_TOP, GROUND_BOTTOM)
    draw = ImageDraw.Draw(canvas)

    w, h = width * SS, height * SS

    # swatch ramp on the right, stepping down as the shades deepen.
    # laid out from a fixed right edge so the chips can never run off canvas.
    chip_count = 6
    left_edge, right_edge = w * 0.600, w * 0.940
    pitch = (right_edge - left_edge) / (chip_count - 1 + 1 / 1.16)
    chip_w = pitch / 1.16
    chip_h = h * 0.46
    origin_y = h * 0.20
    for index in range(chip_count):
        depth = round(4 + (index / (chip_count - 1)) * 22)
        left = left_edge + index * pitch
        top = origin_y + index * h * 0.042
        draw.rounded_rectangle(
            (left, top, left + chip_w, top + chip_h),
            radius=chip_w * 0.30,
            fill=profile_sample_color(depth, "N"),
        )

    title = load_font(DISPLAY_FONT, round(h * 0.152))
    tagline = load_font(BODY_FONT, round(h * 0.055))

    left_margin = w * 0.072
    draw.text((left_margin, h * 0.285), "ShadeMatch", font=title, fill=CREAM)
    draw.text((left_margin, h * 0.445), "Global", font=title, fill=profile_sample_color(11, "W"))
    draw.text((left_margin, h * 0.645), "1,578 shades. 34 brands. Fully offline.", font=tagline, fill=MUTED)

    return canvas.resize((width, height), Image.LANCZOS)


# --- launcher icons --------------------------------------------------------

LAUNCHER_DENSITIES = {
    "mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192,
}


def write_launcher_icons(source: Image.Image, res_dir: Path) -> list[Path]:
    written = []
    for density, px in LAUNCHER_DENSITIES.items():
        target = res_dir / f"mipmap-{density}" / "ic_launcher.png"
        if not target.parent.is_dir():
            continue
        source.resize((px, px), Image.LANCZOS).save(target, "PNG")
        written.append(target)
    return written


# --- main ------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--out", type=Path, default=Path("store_assets"))
    parser.add_argument("--launcher", action="store_true", help="also overwrite android launcher mipmaps")
    args = parser.parse_args()

    args.out.mkdir(parents=True, exist_ok=True)

    icon = build_icon()
    icon_path = args.out / "store_icon_512.png"
    icon.save(icon_path, "PNG")
    print(f"wrote {icon_path} ({icon.width}x{icon.height})")

    feature = build_feature_graphic()
    feature_path = args.out / "feature_graphic_1024x500.png"
    feature.save(feature_path, "PNG")
    print(f"wrote {feature_path} ({feature.width}x{feature.height})")

    if args.launcher:
        for path in write_launcher_icons(icon, Path("android/app/src/main/res")):
            print(f"wrote {path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
