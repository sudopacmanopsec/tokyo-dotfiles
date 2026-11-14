#!/bin/sh
# Waybar music module, event-driven. Any MPRIS player (Waterfox flatpak, Firefox, ...).
# Idle: note icon. Playing/paused: icon + "Artist - Title" (+ repeat marker if on).
# Updates the moment the player changes; no "interval" in the config.
# Exits by itself when Waybar goes away. Needs: playerctl

exec 2>/dev/null
PARENT=$PPID
RT=${XDG_RUNTIME_DIR:-/tmp}
REPEAT=$RT/waybar-music-repeat
last=""

ICON_PLAY=$(printf '\357\201\213')   # U+F04B
ICON_PAUSE=$(printf '\357\201\214')  # U+F04C
ICON_STOP=$(printf '\357\201\215')   # U+F04D
ICON_IDLE=$(printf '\357\200\201')   # U+F001
ICON_REPEAT=$(printf '\357\200\236') # U+F01E

alive() { kill -0 "$PARENT" 2>/dev/null; }

# Escape for Pango markup first, then for JSON. Newlines become spaces.
esc() {
  printf '%s' "$1" | tr '\n' ' ' | sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g'
}

emit() {
  if [ "$1" != "$last" ]; then
    last=$1
    printf '%s\n' "$1" || exit 0
  fi
}

idle() {
  emit "$(printf '{"text":"%s","tooltip":"Nothing playing","class":"idle","alt":"idle"}' "$ICON_IDLE")"
}

render() {
  alive || exit 0
  lines=$(playerctl -a metadata --format '{{status}}|{{artist}}|{{title}}')
  [ -z "$lines" ] && { idle; return; }

  line=$(printf '%s\n' "$lines" | grep -m 1 '^Playing|')
  [ -z "$line" ] && line=$(printf '%s\n' "$lines" | grep -m 1 '^Paused|')
  [ -z "$line" ] && line=$(printf '%s\n' "$lines" | head -n 1)

  status=${line%%|*}
  rest=${line#*|}
  artist=${rest%%|*}
  title=${rest#*|}
  [ -z "$title" ] && { idle; return; }

  case "$status" in
    Playing) icon=$ICON_PLAY;  class="playing" ;;
    Paused)  icon=$ICON_PAUSE; class="paused" ;;
    *)       icon=$ICON_STOP;  class="idle" ;;
  esac

  if [ -n "$artist" ]; then label="$artist - $title"; else label="$title"; fi
  [ -e "$REPEAT" ] && label="$label  $ICON_REPEAT"

  text=$(esc "$icon  $label")
  tip=$(esc "$label")
  emit "$(printf '{"text":"%s","tooltip":"%s","class":"%s","alt":"%s"}' "$text" "$tip" "$class" "$class")"
}

command -v playerctl >/dev/null 2>&1 || { idle; exec sleep 2147483647; }

render
{
  # player events (instant)
  ( while alive; do playerctl --follow metadata --format '{{status}}|{{title}}'; sleep 2; done ) &
  ( while alive; do playerctl --follow status; sleep 2; done ) &
  # repeat flag changes (1s), plus a 5s safety refresh for players that vanish
  ( prev=0; n=0
    while alive; do
      sleep 1; n=$((n + 1)); cur=0; [ -e "$REPEAT" ] && cur=1
      if [ "$cur" != "$prev" ] || [ "$n" -ge 5 ]; then echo tick; prev=$cur; n=0; fi
    done ) &
  wait
} | while IFS= read -r _; do render; done
