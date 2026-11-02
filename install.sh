#!/bin/sh
# Copy each config dir from this repo into ~/.config, creating folders as needed.
# Files that already exist are replaced, with a numbered backup kept (file.~1~).

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

for name in waybar mako mango foot rofi; do
  src="$REPO/$name"
  dest="$CONFIG/$name"

  [ -d "$src" ] || { echo "skip $name (not in repo)"; continue; }

  mkdir -p "$dest"
  cp -r --backup=numbered "$src/." "$dest/"
  echo "installed $name -> $dest"
done
