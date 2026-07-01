#!/usr/bin/env python3
"""Generate the nonlaOS terminal logo from the source PNG asset."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "img" / "launcher_icon.png"
OUTPUT = (
    ROOT
    / "packages"
    / "nonla-branding"
    / "payload"
    / "usr"
    / "share"
    / "nonlaos"
    / "ascii"
    / "nonlaos.ansi"
)

TARGET_WIDTH = 42
ALPHA_THRESHOLD = 24
CHARSET = " .:-=+*#%@"


def visible_bounds(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.point(lambda px: 255 if px > ALPHA_THRESHOLD else 0).getbbox()
    if bbox is None:
        raise SystemExit(f"{SOURCE} has no visible pixels")
    return bbox


def resize_logo(image: Image.Image) -> Image.Image:
    cropped = image.crop(visible_bounds(image))
    width, height = cropped.size
    # Terminal cells are taller than they are wide, so reduce the output height
    # to keep the PNG-derived logo visually close to the source icon.
    target_height = max(2, round((height / width) * TARGET_WIDTH * 0.52))
    return cropped.resize((TARGET_WIDTH, target_height), Image.Resampling.LANCZOS)


def ansi_rgb(pixel: tuple[int, int, int, int]) -> str:
    red, green, blue, _alpha = pixel
    return f"\x1b[38;2;{red};{green};{blue}m"


def glyph_for(pixel: tuple[int, int, int, int]) -> str:
    red, green, blue, alpha = pixel
    if alpha <= ALPHA_THRESHOLD:
        return " "

    brightness = (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
    index = min(len(CHARSET) - 1, max(0, round(brightness * (len(CHARSET) - 1))))
    return CHARSET[index]


def render_ascii(image: Image.Image) -> str:
    lines: list[str] = []
    width, height = image.size

    for y in range(height):
        line_parts: list[str] = []
        for x in range(width):
            pixel = image.getpixel((x, y))
            glyph = glyph_for(pixel)
            if glyph == " ":
                line_parts.append(" ")
            else:
                line_parts.append(f"{ansi_rgb(pixel)}{glyph}")

        lines.append("".join(line_parts).rstrip() + "\x1b[0m")

    return "\n".join(lines) + "\n"


def main() -> None:
    if not SOURCE.exists():
        raise SystemExit(f"Missing source image: {SOURCE}")

    image = Image.open(SOURCE).convert("RGBA")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(render_ascii(resize_logo(image)), encoding="utf-8")
    print(f"Generated {OUTPUT.relative_to(ROOT)} from {SOURCE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
