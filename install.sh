#!/bin/sh
# Install these dotfiles: copy each config dir from this repo into ~/.config,
# plus starship.toml and the helper scripts in bin/.
# An existing config dir is backed up first as <dir>.bak.<timestamp>.
# Portable: works with GNU and BSD (Chimera) userlands.

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BINDIR="$HOME/.local/bin"
STAMP=$(date +%Y%m%d-%H%M%S)

for name in waybar mako mango foot rofi; do
  src="$REPO/$name"
  dest="$CONFIG/$name"

  [ -d "$src" ] || { echo "skip $name (not in repo)"; continue; }

  if [ -d "$dest" ]; then
    cp -R "$dest" "$dest.bak.$STAMP"
    echo "backed up $name -> $dest.bak.$STAMP"
  fi
  mkdir -p "$dest"
  cp -R "$src/." "$dest/"
  echo "installed $name -> $dest"
done

# starship prompt
if [ -f "$REPO/starship/starship.toml" ]; then
  mkdir -p "$CONFIG"
  [ -f "$CONFIG/starship.toml" ] && cp "$CONFIG/starship.toml" "$CONFIG/starship.toml.bak.$STAMP"
  cp "$REPO/starship/starship.toml" "$CONFIG/starship.toml"
  echo "installed starship.toml -> $CONFIG"
fi

# helper scripts (screenshot, ...)
if [ -d "$REPO/bin" ]; then
  mkdir -p "$BINDIR"
  for f in "$REPO"/bin/*; do
    [ -f "$f" ] || continue
    cp "$f" "$BINDIR/"
    chmod +x "$BINDIR/$(basename "$f")"
    echo "installed $(basename "$f") -> $BINDIR"
  done
fi

# waybar scripts need to be executable
[ -d "$CONFIG/waybar/scripts" ] && chmod +x "$CONFIG/waybar/scripts"/* 2>/dev/null || true

echo
echo "Done. Make sure ~/.local/bin is in your PATH, then restart waybar and reload mango."
