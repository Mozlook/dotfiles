#!/usr/bin/env python3
"""Normalize matugen's JSON output into our canonical palette.json.

Usage: matugen2palette.py <matugen.json> <out-palette.json> <theme-name> <wallpaper-basename>

Expects `matugen image ... -j hex -c scripts/matugen.toml` output: Material You
roles in `colors`, plus the blended custom colors (red, green, ...) defined in
matugen.toml. Surfaces/accents come from the tonal roles, semantic and terminal
colors from the custom ones.
"""
import json
import sys


def main():
    src, out, name, wallpaper = sys.argv[1:5]
    colors = json.load(open(src))["colors"]

    def c(key):
        return colors[key]["dark"]["color"].upper()

    palette = {
        "name": name,
        "wallpaper": wallpaper,
        "bg": c("surface"),
        "fg": c("on_surface"),
        "muted": c("outline"),
        "accent": c("primary"),
        "accent2": c("tertiary"),
        "surface0": c("surface_container_low"),
        "surface1": c("surface_container"),
        "surface2": c("surface_container_high"),
        "surface3": c("surface_container_highest"),
        "ok": c("green"),
        "warn": c("yellow"),
        "error": c("error"),
        "info": c("blue"),
        "string": c("yellow"),
        "number": c("magenta"),
        "namespace": c("cyan"),
    }

    # ANSI 0-15: normal = blended hue, bright = its light container tone.
    hues = ["red", "green", "yellow", "blue", "magenta", "cyan"]
    ansi = [c("surface_container_high")]
    ansi += [c(h) for h in hues]
    ansi += [c("on_surface_variant"), c("outline_variant")]
    ansi += [c(f"on_{h}_container") for h in hues]
    ansi += [c("on_surface")]
    for i, value in enumerate(ansi):
        palette[f"color{i}"] = value

    json.dump(palette, open(out, "w"), indent=2)
    print(out)


if __name__ == "__main__":
    main()
