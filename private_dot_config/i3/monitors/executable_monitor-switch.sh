#!/usr/bin/env bash
# Troca perfil de monitor via rofi
# Só mostra perfis cujos outputs estão conectados no momento

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

# Mostra menu rofi
LAST_NAME=$(cat "$LAST" 2>/dev/null || echo "")
CHOICE=$(valid_profiles | \
  rofi -dmenu \
    -p "Monitor" \
    -mesg "Conectados: $(IFS=', '; echo "${CONNECTED[*]}")" \
    -select "$LAST_NAME")

[[ -z "$CHOICE" ]] && exit 0

# Executa o comando do perfil escolhido
CMD=$(grep "^${CHOICE}|" "$PROFILES" | cut -d'|' -f2-)
[[ -z "$CMD" ]] && exit 1

eval "$CMD"
echo "$CHOICE" > "$LAST"

# Reagenda workspaces dinamicamente (primary/nonprimary já resolve)
sleep 0.5
i3-msg reload

# Reinicia polybar e wallpaper
pkill polybar 2>/dev/null || true
sleep 0.3
bash ~/.config/i3/polybar.sh &
nitrogen --restore &

notify-send "Monitor" "Perfil: $CHOICE" --icon=display
