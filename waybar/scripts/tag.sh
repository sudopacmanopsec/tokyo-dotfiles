#!/bin/sh
# Waybar tag module for mangowm. Usage: tag.sh <tag-number>
# Long-running and event-driven: redraws only when `mmsg watch all-tags` reports a
# change (polls once a second if watch is unavailable). No "interval" in the config.
# Exits by itself when Waybar goes away, so restarts don't leave strays behind.
# Shows the screen the bar is on (WAYBAR_OUTPUT_NAME).
# Classes: tag + (focused | urgent) + (occupied | empty)
# Needs: mmsg, jq

exec 2>/dev/null
N=${1:-1}
MON=${WAYBAR_OUTPUT_NAME:-${TAG_MONITOR:-DP-2}}
PARENT=$PPID
last=""

alive() { kill -0 "$PARENT" 2>/dev/null; }

render() {
  alive || exit 0
  out=$(mmsg get all-tags | jq -c --arg m "$MON" --argjson n "$N" '
    ((.all_tags | (map(select(.monitor == $m)) | .[0]) // .[0]).tags[] | select(.index == $n)) as $t
    | {
        text: ($n | tostring),
        tooltip: "\($t.client_count) window(s)",
        class: [
          "tag",
          (if $t.is_active then "focused" else empty end),
          (if $t.is_urgent then "urgent" else empty end),
          (if $t.client_count > 0 then "occupied" else "empty" end)
        ]
      }')
  [ -z "$out" ] && return
  if [ "$out" != "$last" ]; then
    last=$out
    printf '%s\n' "$out" || exit 0
  fi
}

render
while :; do
  alive || exit 0
  mmsg watch all-tags | while IFS= read -r _; do render; done
  sleep 1
  render
done
