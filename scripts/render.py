#!/usr/bin/env python3
"""Render a template against a palette.json.

Usage: render.py <palette.json> <template> <output>

Tokens in the template:
  {{key}}        -> palette value as-is (e.g. "#C47C5A")
  {{key_hex}}    -> hex without leading '#'      (e.g. "C47C5A")  [auto-derived]
  {{key_rgb}}    -> "r, g, b" decimal            (e.g. "196, 124, 90")  [auto-derived]

Any '#rrggbb' value automatically gets _hex and _rgb companions, so templates
for Hyprland (rgb()/rgba()) and GTK (rgba()) need no special palette keys.
"""
import json
import re
import sys


def derive(palette):
    out = {}
    for k, v in palette.items():
        out[k] = v
        if isinstance(v, str) and re.fullmatch(r"#[0-9a-fA-F]{6}", v):
            hexv = v[1:]
            out[f"{k}_hex"] = hexv
            r, g, b = (int(hexv[i:i + 2], 16) for i in (0, 2, 4))
            out[f"{k}_rgb"] = f"{r}, {g}, {b}"
    return out


def main():
    if len(sys.argv) != 4:
        sys.exit("usage: render.py <palette.json> <template> <output>")
    palette_path, template_path, output_path = sys.argv[1:4]

    with open(palette_path) as f:
        values = derive(json.load(f))

    with open(template_path) as f:
        text = f.read()

    missing = set()

    def repl(m):
        key = m.group(1)
        if key in values:
            return str(values[key])
        missing.add(key)
        return m.group(0)

    rendered = re.sub(r"\{\{\s*([a-zA-Z0-9_]+)\s*\}\}", repl, text)

    if missing:
        print(f"render.py: warning: unknown tokens in {template_path}: "
              f"{', '.join(sorted(missing))}", file=sys.stderr)

    with open(output_path, "w") as f:
        f.write(rendered)


if __name__ == "__main__":
    main()
