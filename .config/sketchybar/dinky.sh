#!/bin/sh
# sketchybar workspace updater for dinky.
# Subscribed to: workspace_change, front_app_switched (see sketchybarrc)
# dinky pushes state via [hooks] in dinky.toml, which fires the
# workspace_change event with WORKSPACE set (see https://dinky.rodeo/commands).
#
# States per workspace icon:
#   focused -> white icon on blue pill
#   occupied -> dim white, no pill
#   empty -> barely visible

command -v dinky >/dev/null 2>&1 || exit 0

# WORKSPACE is passed by the dinky workspace-changed hook; fall back to
# querying the CLI when absent (e.g. the first --update at startup).
FOCUSED_WORKSPACE=${WORKSPACE:-$(dinky list-workspaces --focused 2>/dev/null)} || exit 0
OCCUPIED=$(dinky list-windows --all --format '%{workspace}' 2>/dev/null | tr -d ' ' | sort -u)

for sid in 1 2 3 4 5 6; do
  if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set space."$sid" icon.color=0xffffffff background.color=0x407fc8ff
  elif echo "$OCCUPIED" | grep -qx "$sid"; then
    sketchybar --set space."$sid" icon.color=0x99ffffff background.color=0x00000000
  else
    sketchybar --set space."$sid" icon.color=0x33ffffff background.color=0x00000000
  fi
done