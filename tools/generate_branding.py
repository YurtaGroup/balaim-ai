#!/usr/bin/env python3
"""
Generates app icon and splash logo for Balam.AI.
Run: python3 tools/generate_branding.py
Outputs:
  assets/branding/app_icon.png        (1024x1024)
  assets/branding/splash_logo.png     (1024x1024, transparent bg)
"""
from PIL import Image, ImageDraw, ImageFilter
import os
import math

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
os.makedirs(OUT_DIR, exist_ok=True)

# Balam.AI brand colors (from app_colors.dart)
PRIMARY = (232, 120, 122)       # #E8787A coral
PRIMARY_DARK = (204, 92, 94)    # #CC5C5E
WHITE = (255, 255, 255)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def draw_gradient_bg(draw, size):
    """Diagonal gradient from PRIMARY to PRIMARY_DARK."""
    w, h = size, size
    for y in range(h):
        for x in range(w):
            # diagonal: t from 0 (top-left) to 1 (bottom-right)
            t = (x + y) / (w + h)
            r = lerp(PRIMARY[0], PRIMARY_DARK[0], t)
            g = lerp(PRIMARY[1], PRIMARY_DARK[1], t)
            b = lerp(PRIMARY[2], PRIMARY_DARK[2], t)
            draw.point((x, y), fill=(r, g, b))


def draw_gradient_bg_fast(img, size):
    """Fast gradient using per-row horizontal gradient (close enough)."""
    w, h = size, size
    # Create gradient by iterating rows/cols
    pixels = img.load()
    for y in range(h):
        for x in range(w):
            t = (x + y) / (2 * (w - 1))
            r = lerp(PRIMARY[0], PRIMARY_DARK[0], t)
            g = lerp(PRIMARY[1], PRIMARY_DARK[1], t)
            b = lerp(PRIMARY[2], PRIMARY_DARK[2], t)
            pixels[x, y] = (r, g, b, 255)


def draw_jaguar_mark(draw, size, color=WHITE):
    """
    Draws a stylized 'B' / jaguar silhouette mark.
    We use a clean geometric composition:
      - A large soft-rounded square (represents protection/home)
      - A small circle (baby/heart) inside
      - A subtle curve (like a sheltering paw)
    """
    cx, cy = size // 2, size // 2

    # Outer rounded square (protection frame)
    frame_size = int(size * 0.52)
    frame_left = cx - frame_size // 2
    frame_top = cy - frame_size // 2
    radius = int(frame_size * 0.28)
    thickness = int(size * 0.045)

    draw.rounded_rectangle(
        [frame_left, frame_top, frame_left + frame_size, frame_top + frame_size],
        radius=radius,
        outline=color,
        width=thickness,
    )

    # Center heart/baby circle
    heart_radius = int(size * 0.085)
    draw.ellipse(
        [cx - heart_radius, cy - heart_radius,
         cx + heart_radius, cy + heart_radius],
        fill=color,
    )

    # Two small ears on top of frame (jaguar hint)
    ear_size = int(size * 0.09)
    ear_y = frame_top - ear_size // 3
    # Left ear
    draw.polygon([
        (frame_left + int(frame_size * 0.22), ear_y),
        (frame_left + int(frame_size * 0.38), ear_y + ear_size),
        (frame_left + int(frame_size * 0.10), ear_y + ear_size),
    ], fill=color)
    # Right ear
    draw.polygon([
        (frame_left + int(frame_size * 0.78), ear_y),
        (frame_left + int(frame_size * 0.90), ear_y + ear_size),
        (frame_left + int(frame_size * 0.62), ear_y + ear_size),
    ], fill=color)


def make_app_icon(size=1024):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_gradient_bg_fast(img, size)
    draw = ImageDraw.Draw(img)
    draw_jaguar_mark(draw, size)

    out_path = os.path.join(OUT_DIR, "app_icon.png")
    img.save(out_path, "PNG")
    print(f"✅ App icon: {out_path} ({size}x{size})")


def make_splash_logo(size=1024):
    """Splash logo: transparent bg, white mark (bg color set in config)."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    draw_jaguar_mark(draw, size, color=WHITE)
    out_path = os.path.join(OUT_DIR, "splash_logo.png")
    img.save(out_path, "PNG")
    print(f"✅ Splash logo: {out_path} ({size}x{size})")


if __name__ == "__main__":
    make_app_icon()
    make_splash_logo()
    print("Done.")
