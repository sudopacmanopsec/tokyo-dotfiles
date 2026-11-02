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

Each dir is copied into
`~/.config`.

## Dependencies

```sh
sudo xbps-install -S waybar mako foot rofi playerctl pamixer pavucontrol font-iosevka
```

Needs waybar 0.14+ for the `ext/workspaces` module, and a Nerd Font
(JetBrainsMono Nerd Font Propo for waybar and rofi), plus Iosevka for foot.
