#!/bin/sh
# Waybar tags module for mangowm: ONE module draws all tags, so they never disagree.
# Event-driven: redraws when `mmsg watch all-tags` reports a change (falls back to
# polling once a second if watch isn't available). Shows the screen the bar is on.
# empty = dark, has windows = grey underline, current = white + blue underline.
# Needs: mmsg, jq

MON=${WAYBAR_OUTPUT_NAME:-${TAG_MONITOR:-DP-2}}
last=""

render() {
  out=$(mmsg get all-tags 2>/dev/null | jq -c --arg m "$MON" '
    ((.all_tags | (map(select(.monitor == $m)) | .[0]) // .[0]).tags) as $t
    | {
        text: ($t | map(
            if .is_urgent then "<span foreground=\"#f7768e\" underline=\"single\" underline_color=\"#f7768e\">  \(.index)  </span>"
            elif .is_active then "<span foreground=\"#ffffff\" underline=\"single\" underline_color=\"#7aa2f7\">  \(.index)  </span>"
            elif .client_count > 0 then "<span foreground=\"#565f89\" underline=\"single\" underline_color=\"#565f89\">  \(.index)  </span>"
            else "<span foreground=\"#414868\">  \(.index)  </span>" end
          ) | join("")),
        tooltip: ($t | map("\(.index): \(.client_count) window(s)") | join("\n")),
        class: "tags"
      }' 2>/dev/null)
  [ -z "$out" ] && return
  if [ "$out" != "$last" ]; then
    last=$out
    printf '%s\n' "$out"
  fi
}

render
while :; do
  mmsg watch all-tags 2>/dev/null | while IFS= read -r _; do render; done
  sleep 1
  render
done
