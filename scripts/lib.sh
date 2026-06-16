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

# --- service enable (idempotent) ---------------------------------------------
enable_system_service() { systemctl is-enabled "$1" >/dev/null 2>&1 || sudo systemctl enable "$1"; }
enable_user_service()   { systemctl --user is-enabled "$1" >/dev/null 2>&1 || systemctl --user enable "$1"; }
