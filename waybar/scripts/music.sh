#!/usr/bin/env bash

ICON=$'\uf001'

if ! status=$(playerctl status 2>/dev/null); then
    printf '{"text":"%s","class":"idle","tooltip":"No music playing"}\n' "$ICON"
    exit 0
fi

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    track=$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null)

    if [[ -n "$track" ]]; then
        jq -cn \
            --arg text "$ICON  $track" \
            --arg class "${status,,}" \
            '{text:$text,class:$class,tooltip:$text}'
        exit 0
    fi
fi

printf '{"text":"%s","class":"idle","tooltip":"No music playing"}\n' "$ICON"
