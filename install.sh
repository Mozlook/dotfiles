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
  warn "NVIDIA GPU detected — installing drivers + writing env.conf"
  read_pkglist "$DOTS/packages/nvidia.txt" | sudo pacman -S --needed --noconfirm -
  cp "$DOTS/config/hypr/env.nvidia.conf" "$DOTS/config/hypr/env.conf"
else
  : > "$DOTS/config/hypr/env.conf"   # empty env on non-NVIDIA hosts
fi

# --- 5. AUR packages ---------------------------------------------------------
info "Installing AUR packages…"
read_pkglist "$DOTS/packages/aur.txt" | yay -S --needed --noconfirm -

# --- 6. per-host monitor config ---------------------------------------------
if [ ! -f "$DOTS/config/hypr/monitors.conf" ]; then
  info "Generating per-host monitors.conf (preferred mode, auto layout)…"
  if command -v hyprctl >/dev/null && hyprctl monitors >/dev/null 2>&1; then
    hyprctl monitors -j | python3 - "$DOTS/config/hypr/monitors.conf" <<'PY' || cp "$DOTS/config/hypr/monitors.example.conf" "$DOTS/config/hypr/monitors.conf"
import json,sys
mons=json.load(sys.stdin); x=0; out=[]
for m in mons:
    out.append(f"monitor={m['name']},preferred,{x}x0,1")
    x+=m.get('width',1920)
open(sys.argv[1],"w").write("\n".join(out)+"\n")
PY
  else
    cp "$DOTS/config/hypr/monitors.example.conf" "$DOTS/config/hypr/monitors.conf"
    warn "Hyprland not running yet — wrote a fallback monitors.conf (edit after first login)."
  fi
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
  chsh -s /usr/bin/zsh || warn "chsh failed; run 'chsh -s /usr/bin/zsh' manually."
fi

# --- 10. services ------------------------------------------------------------
info "Enabling services…"
# select the SDDM theme (the package only installs it; it must be chosen here)
if pacman -Qq sddm-astronaut-theme >/dev/null 2>&1; then
  sudo install -d /etc/sddm.conf.d
  printf '[Theme]\nCurrent=sddm-astronaut-theme\n' | sudo tee /etc/sddm.conf.d/10-theme.conf >/dev/null
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
