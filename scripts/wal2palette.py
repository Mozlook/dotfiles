#!/usr/bin/env python3
"""Normalize a pywal colors.json into our canonical palette.json.

Usage: wal2palette.py <wal-colors.json> <out-palette.json> <theme-name> <wallpaper-basename>

pywal gives special.{background,foreground} + colors.color0..15. We derive the
material-ish roles (surfaces, accent, semantic colors) that the templates expect.
"""
import json
import sys


def hex2rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb2hex(rgb):
    return "#{:02X}{:02X}{:02X}".format(*(max(0, min(255, int(round(c)))) for c in rgb))


def blend(a, b, t):
    """Mix hex a toward hex b by fraction t (0..1)."""
    ra, rb = hex2rgb(a), hex2rgb(b)
    return rgb2hex(tuple(ra[i] + (rb[i] - ra[i]) * t for i in range(3)))


def saturation(h):
    r, g, b = (c / 255 for c in hex2rgb(h))
    mx, mn = max(r, g, b), min(r, g, b)
    return 0.0 if mx == 0 else (mx - mn) / mx


def main():
    src, out, name, wallpaper = sys.argv[1:5]
    wal = json.load(open(src))
    bg = wal["special"]["background"]
    fg = wal["special"]["foreground"]
    c = wal["colors"]  # color0 .. color15

    # accent = the most saturated mid color; accent2 = next best with a different look
    mids = [c[f"color{i}"] for i in range(1, 7)]
    ranked = sorted(mids, key=saturation, reverse=True)
    accent = ranked[0]
    accent2 = next((x for x in ranked[1:] if x != accent), c["color3"])

    palette = {
        "name": name,
        "wallpaper": wallpaper,
        "bg": bg,
        "fg": fg,
        "muted": blend(fg, bg, 0.45),
        "accent": accent,
        "accent2": accent2,
        "surface0": blend(bg, fg, 0.04),
        "surface1": blend(bg, fg, 0.09),
        "surface2": blend(bg, fg, 0.16),
        "surface3": blend(bg, fg, 0.24),
        "ok": c["color2"],
        "warn": c["color3"],
        "error": c["color1"],
        "info": c["color4"],
        "string": c["color3"],
        "number": c["color5"],
        "namespace": c["color4"],
    }
    for i in range(16):
        palette[f"color{i}"] = c[f"color{i}"]

    json.dump(palette, open(out, "w"), indent=2)
    print(out)


if __name__ == "__main__":
    main()
