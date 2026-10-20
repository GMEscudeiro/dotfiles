#!/usr/bin/env bash
# Dependências de sistema dos dotfiles (apt + i3lock-color). Roda em todo apply,
# mas só pede sudo quando falta algo; sem terminal, só avisa.
set -euo pipefail

PACKAGES=(
  dunst gammastep qalc papirus-icon-theme  # desktop: notificações, luz noturna, calculadora, ícones
  efibootmgr                               # ~/bin/boot-windows
)
# Para compilar o i3lock-color (betterlockscreen) e o que o betterlockscreen usa
I3LOCK_DEPS=(
  autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev
  libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev
  libxcb-randr0-dev libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev
  libxkbcommon-x11-dev libjpeg-dev libgif-dev bc x11-xserver-utils x11-utils imagemagick
)
I3LOCK_COLOR_VERSION="2.13.c.5"

command -v apt-get &>/dev/null || exit 0

need_i3lock=0
i3lock --version 2>&1 | grep -q color || need_i3lock=1

wanted=("${PACKAGES[@]}")
(( need_i3lock )) && wanted+=("${I3LOCK_DEPS[@]}")

missing=()
for p in "${wanted[@]}"; do
  dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "install ok installed" || missing+=("$p")
done

(( ${#missing[@]} == 0 && need_i3lock == 0 )) && exit 0

if ! sudo -n true 2>/dev/null && [[ ! -t 0 ]]; then
  (( need_i3lock )) && missing+=(i3lock-color)
  echo "apt-deps: faltam ${missing[*]}; rode 'chezmoi apply' num terminal." >&2
  exit 0
fi

if (( ${#missing[@]} )); then
  echo "apt-deps: instalando ${missing[*]}"
  sudo apt-get install -y -qq "${missing[@]}"
fi

if (( need_i3lock )); then
  echo "apt-deps: compilando i3lock-color $I3LOCK_COLOR_VERSION"
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  git clone -q --depth 1 --branch "$I3LOCK_COLOR_VERSION" https://github.com/Raymo111/i3lock-color.git "$tmp/i3lock-color"
  (cd "$tmp/i3lock-color" && ./install-i3lock-color.sh)
fi
