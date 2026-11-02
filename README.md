# tokyo-dotfiles

Void Linux / Gentoo + mangowm setup, Tokyo Night theme.

| Dir      | App                            |
| -------- | ------------------------------ |
| `waybar/`| status bar                     |
| `mako/`  | notifications                  |
| `mango/` | mangowm (`config.conf`, binds) |
| `foot/`  | terminal (`foot.ini`)          |
| `rofi/`  | launcher (`config.rasi`)       |

## Install

```sh
git clone https://github.com/sudopacmanopsec/tokyo-dotfiles.git ~/tokyo-dotfiles
cd ~/tokyo-dotfiles
./install.sh
```

Each folder is copied into `~/.config`, creating subfolders as needed.
Existing files are replaced, with a numbered backup kept (`file.~1~`).

## Dependencies

Needs waybar 0.14+ for the `ext/workspaces` module, JetBrainsMono Nerd Font
(waybar, rofi) and Iosevka (foot).

### Void

```sh
sudo xbps-install -S waybar mako foot rofi playerctl pamixer pavucontrol font-iosevka
```

### Gentoo

Use the official binhost so most packages install prebuilt. Newer stage3s
already have it configured in `/etc/portage/binrepos.conf/`. If not:

```sh
# /etc/portage/binrepos.conf/gentoobinhost.conf
[binhost]
priority = 9999
sync-uri = https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64/
```

```sh
# /etc/portage/make.conf
FEATURES="${FEATURES} getbinpkg"
```

A binary is only used if the package's USE flags match the binhost's build,
otherwise Portage compiles it locally.

mangowm lives in the community GURU overlay and is always built from source:

```sh
emerge --ask eselect-repository
eselect repository enable guru
emerge --sync guru

echo "gui-libs/scenefx ~amd64" >> /etc/portage/package.accept_keywords/mango
echo "gui-wm/mangowm ~amd64"   >> /etc/portage/package.accept_keywords/mango

emerge -av --getbinpkg gui-apps/waybar gui-apps/foot gui-apps/mako gui-wm/mangowm
```

Then the rest. Check names with `emerge -s <name>` or `eix <name>`, as rofi and
the font packages in particular may be named differently:

```sh
emerge -av --getbinpkg x11-misc/rofi media-sound/playerctl media-sound/pamixer \
  media-sound/pavucontrol media-fonts/iosevka
```

Waybar needs `mpris`, `pulseaudio` and `tray` USE flags for the modules used
here. Setting custom flags may mean waybar compiles instead of using the binhost.

```sh
echo "gui-apps/waybar mpris pulseaudio wifi tray" >> /etc/portage/package.use/waybar
```
