#!/usr/bin/env bash
# Shared helpers for the dotfiles installer. Sourced by install.sh.

# --- pretty output -----------------------------------------------------------
c_reset=$'\e[0m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'
info()  { printf '%s::%s %s\n' "$c_blue"  "$c_reset" "$*"; }
ok()    { printf '%s::%s %s\n' "$c_green" "$c_reset" "$*"; }
warn()  { printf '%s::%s %s\n' "$c_yellow" "$c_reset" "$*"; }
die()   { printf '%s::%s %s\n' "$c_red"   "$c_reset" "$*" >&2; exit 1; }

# --- package list parsing ----------------------------------------------------
# Reads a package list file, stripping comments and blank lines.
read_pkglist() {
  [ -f "$1" ] || return 0
  sed -e 's/#.*$//' -e 's/[[:space:]]*$//' "$1" | grep -v '^[[:space:]]*$'
}

# --- AUR helper bootstrap ----------------------------------------------------
ensure_yay() {
  if command -v yay >/dev/null 2>&1; then ok "yay already installed"; return; fi
  info "Bootstrapping yay (AUR helper)…"
  sudo pacman -S --needed --noconfirm base-devel git
  local tmp; tmp="$(mktemp -d)"
  git clone --depth=1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
  rm -rf "$tmp"
  command -v yay >/dev/null 2>&1 || die "yay installation failed"
}

# --- GPU detection -----------------------------------------------------------
has_nvidia() { lspci 2>/dev/null | grep -qiE 'nvidia'; }

# Which driver branch the NVIDIA GPU needs, from its chip codename in lspci
# (e.g. "NVIDIA Corporation GP107 [GeForce GTX 1050 Ti]"):
#   open   — Turing and newer (TU/GA/AD/GB/GH): nvidia-open-dkms from extra
#   580xx  — Maxwell/Pascal/Volta (GM/GP/GV): dropped by the 590+ driver,
#            last supported branch is 580xx (AUR)
#   legacy — Kepler and older (or unknown chip): no current driver, stay on nouveau
# With several NVIDIA GPUs the oldest one decides (580xx also drives newer chips).
nvidia_branch() {
  local chips
  chips="$(lspci 2>/dev/null | grep -iE '(vga|3d|display).*nvidia' \
           | grep -oE '\b(G[KMPVAHB]|TU|AD)[0-9]{3}' || true)"
  if [ -z "$chips" ]; then echo legacy
  elif grep -qE '^GK' <<<"$chips"; then echo legacy
  elif grep -qE '^(GM|GP|GV)' <<<"$chips"; then echo 580xx
  else echo open
  fi
}

# "<kernel>-headers" for every installed official kernel (needed by dkms).
kernel_headers() {
  local k
  for k in linux linux-lts linux-zen linux-hardened; do
    pacman -Qq "$k" >/dev/null 2>&1 && echo "$k-headers"
  done
  return 0
}

# --- service enable (idempotent) ---------------------------------------------
enable_system_service() { systemctl is-enabled "$1" >/dev/null 2>&1 || sudo systemctl enable "$1"; }
enable_user_service()   { systemctl --user is-enabled "$1" >/dev/null 2>&1 || systemctl --user enable "$1"; }
