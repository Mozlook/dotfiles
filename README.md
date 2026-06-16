# dotfiles

Reproducible Arch Linux + Hyprland desktop with wallpaper-driven theming.

Cozy/modern setup around **zsh · Hyprland · Waybar · Neovim**, with a rofi
wallpaper picker that recolors every app to match the wallpaper.

## Install (fresh machine)

Needs only `git` + `pacman` to start:

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then reboot → SDDM → Hyprland.

`install.sh` is idempotent: it bootstraps `yay`, installs packages
(`packages/*.txt`), auto-detects NVIDIA, symlinks configs with GNU `stow`,
sets zsh as the shell, enables services, and applies the default theme.

## Theming

- **Pick a wallpaper:** `SUPER+T` → rofi thumbnail grid. Selection swaps the
  wallpaper (swww) and recolors Waybar, kitty, rofi, swaync, Hyprland borders,
  starship and Neovim — live, no logout.
- **Curated palettes** live in `themes/<name>/palette.json` (hand-tuned).
- **New wallpaper:** the picker's “＋ Add wallpaper…” entry runs **matugen** to
  generate a palette, caches it under `themes/<name>/`, then applies it.
- CLI: `theme-set <name>`, `theme-gen <image>`, `wallpaper-picker`.

Default theme is **cafe** (warm terracotta / cream / dark green).

## Layout

| Path | What |
|---|---|
| `install.sh` | bootstrap entrypoint |
| `packages/` | pacman / aur / nvidia package lists |
| `config/` | stowed into `~/.config` |
| `home/` | stowed into `~` (`.zshrc`, …) |
| `bin/` | `theme-set`, `theme-gen`, `wallpaper-picker` → `~/.local/bin` |
| `themes/` | curated palettes + per-app render templates |

Per-host files (`config/hypr/monitors.conf`, `env.conf`) and rendered color
files are generated and gitignored.

## Keybinds

`SUPER`: `Return` kitty · `SPACE` rofi · `C` close · `F` fullscreen ·
`V` float · `B` brave · `D` discord · `N` nautilus · `O` obsidian · `L` lock ·
`T` theme picker · `1/2/3 Q/W/E` workspaces (`+SHIFT` move) · `S` scratchpad ·
`Print` screenshots.
