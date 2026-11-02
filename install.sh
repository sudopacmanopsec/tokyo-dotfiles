#!/bin/sh
# Symlink each config dir from this repo into ~/.config.
# Existing non-symlink dirs are backed up to <name>.bak first.

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$CONFIG"

for name in waybar mako mango foot rofi; do
  src="$REPO/$name"
  dest="$CONFIG/$name"

  [ -d "$src" ] || { echo "skip $name (not in repo)"; continue; }

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "backing up $dest -> $dest.bak"
    mv "$dest" "$dest.bak"
  fi

  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
done
