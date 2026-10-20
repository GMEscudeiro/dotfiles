#!/usr/bin/env bash
# Troca perfil de monitor via rofi
# Só mostra perfis cujos outputs estão conectados no momento
#
# Uso:
#   monitor-switch.sh          → restaura último perfil salvo (ou abre Rofi se nenhum)
#   monitor-switch.sh --pick   → força abertura do Rofi

PROFILES="$HOME/.config/i3/monitors/profiles.conf"
LAST="$HOME/.config/i3/monitors/.last_profile"

# Outputs conectados agora
mapfile -t CONNECTED < <(xrandr | awk '/ connected/ {print $1}')

# Filtra perfis válidos para o hardware atual
valid_profiles() {
  while IFS='|' read -r name cmd || [[ -n "$name" ]]; do
    [[ "$name" =~ ^#|^$ ]] && continue

    # Extrai os --output do comando e verifica se todos estão conectados
    ok=true
    while read -r out; do
      if [[ "$out" == "--off" ]]; then continue; fi
      if ! printf '%s\n' "${CONNECTED[@]}" | grep -qx "$out"; then
        ok=false
        break
      fi
    done < <(echo "$cmd" | grep -oP '(?<=--output )\S+')

    $ok && echo "$name"
  done < "$PROFILES"
}

pick_profile() {
  local last_name
  last_name=$(cat "$LAST" 2>/dev/null || echo "")
  valid_profiles | \
    rofi -dmenu \
      -p "Monitor" \
      -mesg "Conectados: $(IFS=', '; echo "${CONNECTED[*]}")" \
      -select "$last_name"
}

# ── Modo: restaurar ou picker ─────────────────────────────────────────────────
if [[ "$1" == "--pick" ]]; then
  CHOICE=$(pick_profile)
elif [[ -f "$LAST" ]]; then
  CHOICE=$(cat "$LAST")
  # Valida que o perfil salvo ainda é compatível com os monitores conectados
  if ! valid_profiles | grep -qx "$CHOICE"; then
    CHOICE=$(pick_profile)
  fi
else
  CHOICE=$(pick_profile)
fi

[[ -z "$CHOICE" ]] && exit 0

# Executa o comando do perfil escolhido
CMD=$(grep "^${CHOICE}|" "$PROFILES" | cut -d'|' -f2-)
[[ -z "$CMD" ]] && exit 1

eval "$CMD"
echo "$CHOICE" > "$LAST"

# ── Redistribui workspaces após xrandr ────────────────────────────────────────
redistribute_workspaces() {
  local primary nonprimary
  primary=$(xrandr | awk '/ connected primary/ {print $1}')
  nonprimary=$(xrandr | awk '/ connected/ && !/ primary/ {print $1}' | head -1)

  # [workspace=...] casa janelas, não workspaces — workspaces vazios (ex: os
  # criados no boot) nunca seriam movidos. Por isso foca cada um e move.
  local focused ws target
  focused=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name')

  while IFS= read -r ws; do
    case "$ws" in
      *": P"*) target=$primary ;;
      *": S"*) target=$nonprimary ;;
      *) continue ;;
    esac
    [[ -z "$target" ]] && continue
    i3-msg "workspace --no-auto-back-and-forth \"$ws\"; move workspace to output $target" >/dev/null 2>&1 || true
  done < <(i3-msg -t get_workspaces | jq -r '.[].name')

  [[ -n "$focused" ]] && i3-msg "workspace --no-auto-back-and-forth \"$focused\"" >/dev/null 2>&1
}

sleep 0.5
redistribute_workspaces

pkill polybar 2>/dev/null || true
sleep 0.3
bash ~/.config/i3/polybar.sh &
nitrogen --restore &

# ── Tema Dark ─────────────────────────────────────────────────────────────────
apply_dark_theme() {
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
  fi

  mkdir -p "$HOME/.config/gtk-2.0"
  cat > "$HOME/.gtk-2.0/gtkrc" 2>/dev/null || \
  cat > "$HOME/.gtkrc-2.0" <<EOF
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Adwaita"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
EOF

  mkdir -p "$HOME/.config/gtk-3.0"
  cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

  mkdir -p "$HOME/.config/gtk-4.0"
  cat > "$HOME/.config/gtk-4.0/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
EOF

  if ! grep -q 'QT_STYLE_OVERRIDE' "$HOME/.zshenv" 2>/dev/null; then
    echo 'export QT_STYLE_OVERRIDE=adwaita-dark' >> "$HOME/.zshenv"
  fi
}

apply_dark_theme

notify-send "Monitor" "Perfil: $CHOICE" --icon=display
