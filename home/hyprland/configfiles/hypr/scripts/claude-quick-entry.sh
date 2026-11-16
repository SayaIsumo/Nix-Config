#!/usr/bin/env bash
# Trigger Claude Desktop's Quick Entry through the GlobalShortcuts portal.
# The shortcut ID contains a hash, so look it up instead of hardcoding it.

id=$(hyprctl globalshortcuts | awk -F' -> ' '/^claude:/ { print $1; exit }')

if [ -z "$id" ]; then
    hyprctl notify 0 3000 0 "Claude Quick Entry: Claude Desktop isn't running" > /dev/null
    exit 1
fi

hyprctl dispatch "hl.dsp.global(\"$id\")" > /dev/null
