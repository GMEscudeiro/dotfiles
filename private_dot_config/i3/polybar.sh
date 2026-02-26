#!/usr/bin/env bash

PATH=$PATH:/usr/local/bin

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

sleep 1

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    is_primary=$(xrandr --query | grep "$m" | grep "primary")
    if [ ! -z "$is_primary" ]; then
      MONITOR=$m polybar --reload pbar &
    else
      MONITOR=$m polybar --reload sbar &
    fi
  done
else
  polybar --reload pbar &
fi
