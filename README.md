# tokyo-dotfiles

Void Linux + mangowm setup, Tokyo Night theme.

| Dir      | App                          |
| -------- | ---------------------------- |
| `waybar/`| status bar                   |
| `mako/`  | notifications                |
| `mango/` | mangowm (`config.conf`, binds) |
| `foot/`  | terminal (`foot.ini`)        |
| `rofi/`  | launcher (`config.rasi`)     |

## Install

```sh
git clone https://github.com/sudopacmanopsec/tokyo-dotfiles.git ~/tokyo-dotfiles
cd ~/tokyo-dotfiles
./install.sh
```

Existing configs are moved to `<name>.bak`, then each dir is symlinked into
`~/.config`.

## Dependencies

```sh
sudo xbps-install -S waybar mako foot rofi playerctl pamixer pavucontrol
```

Needs waybar 0.14+ for the `ext/workspaces` module, and a Nerd Font
(JetBrainsMono Nerd Font Propo).
