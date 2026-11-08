#!/usr/bin/env bash

awww-daemon &
# wait for the daemon socket before setting the image
until awww query >/dev/null 2>&1; do sleep 0.1; done
awww img "$HOME/Pictures/Wallpapers/wallpaper.jpg"
