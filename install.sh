#!/usr/bin/env bash
# Dotfiles bootstrap. Fresh Arch with git+pacman -> full Hyprland desktop.
# Idempotent: safe to re-run. Usage: ./install.sh
set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTS/scripts/lib.sh"

[ -f /etc/arch-release ] || die "This installer targets Arch Linux."
command -v pacman >/dev/null || die "pacman not found."
[ "$(id -u)" -ne 0 ] || die "Run as your normal user (not root); sudo is used where needed."

info "Dotfiles root: $DOTS"
sudo -v

# --- 1. system update + base tools ------------------------------------------
info "Syncing repos and base tooling…"
sudo pacman -Syu --needed --noconfirm base-devel git stow

# --- 2. AUR helper -----------------------------------------------------------
ensure_yay

# --- 3. official packages ----------------------------------------------------
info "Installing official packages…"
read_pkglist "$DOTS/packages/pacman.txt" | sudo pacman -S --needed --noconfirm -

# --- 4. GPU-specific ---------------------------------------------------------
if has_nvidia; then
  warn "NVIDIA GPU detected — installing drivers + writing env.conf/env.lua"
  read_pkglist "$DOTS/packages/nvidia.txt" | sudo pacman -S --needed --noconfirm -
  cp "$DOTS/config/hypr/env.nvidia.conf" "$DOTS/config/hypr/env.conf"
  cp "$DOTS/config/hypr/env.nvidia.lua"  "$DOTS/config/hypr/env.lua"
else
  : > "$DOTS/config/hypr/env.conf"   # empty env on non-NVIDIA hosts
  : > "$DOTS/config/hypr/env.lua"
fi

# --- 5. AUR packages ---------------------------------------------------------
info "Installing AUR packages…"
read_pkglist "$DOTS/packages/aur.txt" | yay -S --needed --noconfirm -

# --- 6. per-host monitor config ---------------------------------------------
# monitors.conf (legacy hyprlang) + monitors.lua (Hyprland 0.55+). Both gitignored.
if [ ! -f "$DOTS/config/hypr/monitors.lua" ]; then
  if command -v hyprctl >/dev/null && hyprctl monitors >/dev/null 2>&1; then
    info "Generating per-host monitor layout (preferred mode, auto)…"
    hyprctl monitors -j | python3 - "$DOTS/config/hypr" <<'PY' || true
import json, os, sys
d = sys.argv[1]
mons = json.load(sys.stdin); x = 0; conf = []; lua = []
for m in mons:
    name = m["name"]
    conf.append(f"monitor={name},preferred,{x}x0,1")
    lua.append(f'hl.monitor({{ output = "{name}", mode = "preferred", position = "{x}x0", scale = 1 }})')
    x += m.get("width", 1920)
# don't clobber a hand-edited monitors.conf
if not os.path.exists(f"{d}/monitors.conf"):
    open(f"{d}/monitors.conf", "w").write("\n".join(conf) + "\n")
open(f"{d}/monitors.lua", "w").write("\n".join(lua) + "\n")
PY
  else
    warn "Hyprland not running yet — using fallback monitor layout (edit after first login)."
  fi
  # ensure both files exist (fallbacks if auto-detect was skipped or failed)
  [ -f "$DOTS/config/hypr/monitors.conf" ] || cp "$DOTS/config/hypr/monitors.example.conf" "$DOTS/config/hypr/monitors.conf"
  [ -f "$DOTS/config/hypr/monitors.lua" ]  || cp "$DOTS/config/hypr/monitors.example.lua"  "$DOTS/config/hypr/monitors.lua"
fi

# --- 7. symlink dotfiles -----------------------------------------------------
# Two stow packages with different targets:
#   config/* -> ~/.config/*      home/* -> ~/*
info "Symlinking configs with stow…"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
stow_pkg() {
  local pkg="$1" target="$2"
  mkdir -p "$target"
  # Back up real (non-symlink) files that would collide, so stow won't abort.
  while IFS= read -r f; do
    local rel="${f#"$DOTS/$pkg/"}" tgt
    tgt="$target/$rel"
    if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
      warn "Backing up existing $tgt -> $tgt.bak"
      mkdir -p "$(dirname "$tgt")"
      mv "$tgt" "$tgt.bak"
    fi
  done < <(find "$DOTS/$pkg" -type f)
  stow --dir="$DOTS" --target="$target" --restow "$pkg"
}
stow_pkg config "$HOME/.config"
stow_pkg home   "$HOME"

# --- 8. theme tooling on PATH ------------------------------------------------
for s in "$DOTS"/bin/*; do ln -sf "$s" "$HOME/.local/bin/$(basename "$s")"; done

# --- 9. default shell --------------------------------------------------------
if [ "${SHELL:-}" != "/usr/bin/zsh" ]; then
  info "Setting zsh as default shell…"
  # via sudo (still cached from above) so chsh doesn't prompt for the password again
  sudo chsh -s /usr/bin/zsh "$(id -un)" || warn "chsh failed; run 'chsh -s /usr/bin/zsh' manually."
fi

# --- 10. services ------------------------------------------------------------
info "Enabling services…"
# select + theme the SDDM login screen (theme-aware: follows SUPER+T)
if pacman -Qq sddm-astronaut-theme >/dev/null 2>&1; then
  sudo install -d /etc/sddm.conf.d
  printf '[Theme]\nCurrent=sddm-astronaut-theme\n' | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
  # passwordless helper: copies the user-rendered login theme into the
  # root-owned theme dir; called by theme-set on every theme switch.
  sudo install -Dm755 "$DOTS/scripts/sddm-sync" /usr/local/bin/sddm-sync
  printf '%s ALL=(root) NOPASSWD: /usr/local/bin/sddm-sync\n' "$(id -un)" \
    | sudo tee /etc/sudoers.d/99-sddm-sync >/dev/null
  sudo chmod 440 /etc/sudoers.d/99-sddm-sync
  sudo visudo -cf /etc/sudoers.d/99-sddm-sync >/dev/null \
    || { warn "sudoers rule invalid — removing it"; sudo rm -f /etc/sudoers.d/99-sddm-sync; }
  # point the astronaut theme at our generated config
  meta=/usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
  [ -f "$meta" ] && sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/dotfiles.conf|' "$meta"
fi
enable_system_service sddm.service
enable_system_service NetworkManager.service
enable_system_service bluetooth.service
systemctl --user daemon-reload 2>/dev/null || true
enable_user_service pipewire.service        || true
enable_user_service wireplumber.service     || true
enable_user_service pipewire-pulse.service  || true

# --- 11. fonts + first theme -------------------------------------------------
fc-cache -f >/dev/null 2>&1 || true
info "Rendering default theme (cafe)…"
"$HOME/.local/bin/theme-set" --render-only cafe || warn "theme-set will run on first Hyprland login instead."

ok "Done. Reboot -> SDDM -> Hyprland."
echo "   Monitor layout: $DOTS/config/hypr/monitors.conf (per-host, gitignored)."
echo "   Change themes anytime with SUPER+T."
