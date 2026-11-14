#!/bin/sh
# Click handler for the music module.
#   on-click (single)        -> waits a moment, then play/pause unless a double click came
#   on-double-click (double) -> cancels the pending play/pause and toggles repeat
# Usage: music-click.sh [double]
# Needs: playerctl

DIR=$(dirname "$0")
RT=${XDG_RUNTIME_DIR:-/tmp}
F=$RT/waybar-music-click
R=$RT/waybar-music-repeat
WAIT=${MUSIC_DOUBLE_CLICK_WAIT:-0.5}

toggle_repeat() {
  if [ -e "$R" ]; then
    rm -f "$R"
  else
    nohup sh "$DIR/music-repeat.sh" >/dev/null 2>&1 &
  fi
}

if [ "$1" = double ]; then
  rm -f "$F"          # cancel the pending single click
  toggle_repeat
  exit 0
fi

if [ -e "$F" ]; then
  # fallback: a second plain click arrived while one was pending
  rm -f "$F"
  toggle_repeat
  exit 0
fi

echo $$ > "$F"
sleep "$WAIT"
if [ "$(cat "$F" 2>/dev/null)" = "$$" ]; then
  rm -f "$F"
  playerctl play-pause
fi
