# tokyo-dotfiles

mangowm + Tokyo Night. Waybar, mako, rofi, foot and zsh.

## Pics

![waybar](screenshots/waybar-real.png)

<img src="screenshots/rofi-real.png" alt="rofi" height="300">

![full](screenshots/full-real.png)

## What's in here

| Dir      | App                                   |
| -------- | ------------------------------------- |
| `waybar/`| status bar                            |
| `mako/`  | notifications                         |
| `mango/` | mangowm (`config.conf`, binds, autostart) |
| `foot/`  | terminal (`foot.ini`)                 |
| `rofi/`  | launcher (`styles.rasi`, scripts)     |
| `zsh/`   | `.zshrc`                              |

## Install

```sh
git clone https://github.com/sudopacmanopsec/tokyo-dotfiles.git ~/tokyo-dotfiles
cd ~/tokyo-dotfiles
./install.sh
cp zsh/.zshrc ~/.zshrc
```

`install.sh` copies each folder into `~/.config` and keeps a numbered backup
(`file.~1~`) of anything it replaces. It does not touch `~/.zshrc`, so that is
the manual `cp` line above. **Read "Before you install" first.**

## Dependencies

### Required

| What                    | Why                                         |
| ----------------------- | ------------------------------------------- |
| mangowm (+ wlroots 0.19, scenefx) | the compositor                    |
| waybar **0.14+**        | needs the `ext/workspaces` module           |
| mako                    | notifications                               |
| foot                    | terminal                                    |
| rofi                    | launcher                                    |
| playerctl               | media pill and its click actions            |
| pavucontrol             | volume click action                         |
| PipeWire or PulseAudio  | provides `pactl` for the volume module      |
| libnotify               | `notify-send`, for testing mako             |
| grim, slurp             | screenshots                                 |
| zsh, starship           | shell and prompt                            |
| zsh-syntax-highlighting | loaded by `.zshrc`                          |
| zsh-autosuggestions     | loaded by `.zshrc` (or cloned to `~/.zsh/`) |
| JetBrains Mono          | waybar and rofi                             |
| Iosevka                 | foot                                        |
| Nerd Font symbols       | icon glyphs in the bar, rofi and foot       |
| Papirus icon theme      | rofi icons                                  |

### Optional

fastfetch (the `ff` alias), btop (click action on the CPU and RAM pills),
blueman (bluetooth pill click action, only if you have bluetooth).

### Gentoo

Use the official binhost so most of this installs prebuilt. Newer stage3s
already have it in `/etc/portage/binrepos.conf/`. Add `getbinpkg` to
`FEATURES` in `make.conf` if it is missing, then install with `--getbinpkg`.

**Enable:**

- The GURU overlay (`eselect repository enable guru`), for mangowm and
  zsh-autosuggestions.
- `~amd64` keywords for `gui-wm/mangowm`, `gui-libs/scenefx` and
  `app-shells/zsh-autosuggestions` in `/etc/portage/package.accept_keywords/`.
- The waybar USE flags for the modules used here. Check the exact names with
  `equery uses gui-apps/waybar` (you want the mpris, pulseaudio, network and
  tray support).

```sh
emerge -av --getbinpkg gui-apps/waybar gui-apps/mako gui-apps/foot \
  x11-misc/rofi gui-apps/grim gui-apps/slurp media-fonts/jetbrains-mono \
  media-fonts/iosevka media-fonts/symbols-nerd-font gui-wm/mangowm
```

These names are from memory, so confirm them with `eix <name>` before you
rely on them: `media-sound/playerctl`, `media-sound/pavucontrol`,
`x11-libs/libnotify`, `app-shells/zsh`, `app-shells/starship`,
`app-shells/zsh-syntax-highlighting`, `x11-themes/papirus-icon-theme`,
`app-misc/fastfetch`, `sys-process/btop`.

**Don't install:**

- `media-sound/pamixer`. It is only in GURU and is keyword-masked. The mute
  action works with `pactl` instead.
- The full `nerdfonts` package unless you want the exact patched font names.
  The symbols font above covers the icons.

### Void

**Enable:**

- A running D-Bus session and a PipeWire or PulseAudio server (mako and the
  volume module need both).
- mangowm is not in the main repos. Build it from source (wlroots 0.19 and
  scenefx first) using the mangowm installation wiki.

```sh
sudo xbps-install -S waybar mako foot rofi playerctl pavucontrol libnotify \
  grim slurp zsh starship zsh-syntax-highlighting zsh-autosuggestions \
  papirus-icon-theme fastfetch btop font-iosevka
```

JetBrains Mono and the Nerd Font symbols are not in that list. Check
`xbps-query -Rs jetbrains` and `xbps-query -Rs nerd`, or put the Nerd Fonts
release tarballs in `~/.local/share/fonts/`. Run `fc-cache -fv` afterwards.

**Don't install:**

- Both `pulseaudio` and `pipewire-pulse`. They conflict, pick one.

## Before you install (so nothing breaks)

**1. Back up what you have.**

```sh
mkdir -p ~/config-backup
cp -r ~/.config/{waybar,mako,mango,foot,rofi} ~/config-backup/ 2>/dev/null
cp ~/.zshrc ~/config-backup/ 2>/dev/null
```

**2. Fonts first.** If the fonts below are missing, the bar shows empty boxes
instead of icons. After installing them, run `fc-cache -fv` and check with
`fc-list | grep -iE "jetbrains|iosevka|symbols"`.

**3. After installing, change these to match your machine.**

- **Paths and username.** Search the mango files and `rofi/scripts/` for
  `/home/`, which points at another user's home. Replace it with yours.
- **Autostart and binds.** Every command launched from
  `mango/autostart.conf` and `mango/bind.conf` has to be installed. A bind that
  launches a missing app does nothing, with no error.
- **Display settings.** Monitor names, scale and refresh rate in
  `mango/config.conf` are specific to one machine. Check yours and update them.
  The same goes for keyboard layout and touchpad settings.
- **Wallpaper script.** Open `rofi/scripts/wallpaper.sh` and check which
  wallpaper tool it calls, then install that tool and point the script at your
  wallpaper folder.
- **Logo.** `waybar/config.jsonc` has a distro logo glyph in the `custom/void`
  block. Use `\uf32e` for Void or `\uf30d` for Gentoo.
- **Volume mute action.** If the config calls `pamixer -t` and you don't have
  `pamixer`, change it to `pactl set-sink-mute @DEFAULT_SINK@ toggle`.
- **Fonts by name.** If you installed plain fonts instead of the patched Nerd
  Font versions, change the font names in `waybar/style.css`,
  `rofi/styles.rasi` and the `font=` line in `foot/foot.ini` to the families
  you have, and add `Symbols Nerd Font` as a fallback.
- **Desktops.** The battery pill hides itself without a battery, and the
  bluetooth pill hides without a controller. Nothing to change.

**4. Check each piece after the first login.**

```sh
waybar                        # run in a terminal to see any errors
rofi -show drun               # prints theme errors if the theme is broken
notify-send "test" "hello"    # tests mako
fc-list | grep -i nerd        # confirms icon fonts
```
