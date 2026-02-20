#!/usr/bin/env bash

# Garante que o script saiba onde encontrar os comandos
PATH=$PATH:/usr/local/bin

# Mata instâncias anteriores
killall -q polybar

# Espera até que os processos tenham sido encerrados
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

sleep 1

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload --config=$HOME/.config/polybar/config.ini mybar >> /tmp/polybar.log 2>&1 &
  done
else
  polybar --reload --config=$HOME/.config/polybar/config.ini mybar >> /tmp/polybar.log 2>&1 &
fi
