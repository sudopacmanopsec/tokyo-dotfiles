#!/bin/sh
# Repeat watcher: restarts the current track just before it ends.
# Works with players that don't support MPRIS LoopStatus (Waterfox/Firefox).
# Runs only while the flag file exists; music-click.sh creates/removes it.
# Debug: `cat $XDG_RUNTIME_DIR/waybar-music-repeat.log` shows what it last saw
# (status, position, length in microseconds). If length is empty, the site
# doesn't expose the track length and repeat can't work there.
F=${XDG_RUNTIME_DIR:-/tmp}/waybar-music-repeat
echo $$ > "$F"
while [ -e "$F" ]; do
  set -- $(playerctl metadata --format '{{status}} {{position}} {{mpris:length}}' 2>/dev/null)
  printf '%s %s %s\n' "$1" "$2" "$3" > "$F.log"
  if [ "$1" = Playing ] && [ "${3:-0}" -gt 0 ] 2>/dev/null; then
    rem=$(( $3 - ${2:-0} ))
    [ "$rem" -lt 1500000 ] && playerctl position 0
  fi
  sleep 0.5
done
