#!/usr/bin/env bash

# Garante que o script saiba onde encontrar os comandos
PATH=$PATH:/usr/local/bin

# Mata instâncias anteriores
killall -q polybar

# Espera até que os processos tenham sido encerrados
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

sleep 1

polybar --config=$HOME/.config/polybar/config.ini mybar >> /tmp/polybar.log 2>&1 &
