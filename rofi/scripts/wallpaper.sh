#!/usr/bin/env bash

# 1. Define your wallpaper directory
WALL_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALL_DIR" ]; then
    notify-send "Wallpaper Error" "Directory $WALL_DIR does not exist."
    exit 1
fi

# 2. Open Rofi to select an image
CHOICE=$(ls "$WALL_DIR" | rofi -dmenu -p " 🖼️ Choose Wallpaper" -config ~/.config/rofi/config.rasi)

# Exit cleanly if the user hits Escape
if [ -z "$CHOICE" ]; then
    exit 0
fi

# 3. Kill any currently running swaybg instances so they don't stack up in memory
pkill swaybg

# 4. Launch swaybg in the background with the new wallpaper
swaybg -i "$WALL_DIR/$CHOICE" -m fill &

# Optional: Desktop notification
notify-send "Wallpaper Changed" "Applied: $CHOICE"

