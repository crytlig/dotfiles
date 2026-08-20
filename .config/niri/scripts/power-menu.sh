#!/usr/bin/bash

# key value pair
declare -A prompt=(
  [" Lock"]="swaylock"
  [" Log out"]="niri msg action quit --skip-confirmation"
  [" Power off"]="systemctl poweroff"
  [" Reboot"]="systemctl reboot"
  ["󰤄 Suspend"]="systemctl suspend"
)

# !prompt[@] == keys. prompt[@] == values
choice=$(printf '%s\n' "${!prompt[@]}" | sort | fuzzel --dmenu --prompt="  ")

# check choice is set and eval
[[ -n "$choice" ]] && eval "${prompt[$choice]}"
