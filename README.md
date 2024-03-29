# env

My linux setup. At home, this is Arch. A work in progress.

* wm: i3
* bar: polybar
* lock: xautolock, i3lock
* composite manager: compton
* terminal: urxvt
* app launcher: rofi
* image viewer: feh
* pdf viewer: zathura

### Installation

WARNING: this will overwrite any existing dotfiles, so back them up first.

```shell
cd ~
git clone https://github.com/avanpo/.env.git
./.env/setup.sh

# or if setting up a server...
# ./.env/setup_server.sh
```

Installing to `~/.env` is required, all configs assume this to be the location
of scripts and various media.

### Configuration

All configuration custom to a machine should go into a file located at
`~/.config/bashrc`. This file is sourced at the end of `~/.bashrc`.

For local machine installed using `setup.sh`, this file should contain the
following environment variable:

```
export SETUP=laptop
```

Optional vars:

```
# for the polybar weather script
export OPENWEATHERMAP_API_KEY=key
```

### Generic tools & troubleshooting

Some useful packages:

```
$ sudo pacman -S usbutils
```

To troubleshoot keyboard mappings and i3 configuration, use `xmodmap -pke` to
get current keycode mappings and `sudo evtest` to get the codes when certain
keys are pressed.

On the Zephyrus G14, the mute mic button didn't map as expected. This should be
fixed in a future kernel release.

### Display

Both `xorg-backlight` and `acpilight` packages provide the tool `xbacklight`,
which controls brightness.

This requires root but both packages install udev rules that allow users to
change them. Note that they are different rules, so installing one over the
other will require a restart.

On the Zephyrus G14, xorg-backlight didn't work (or show any errors). Installing
`acpilight` fixed the problem (after rebooting).

Note that `acpilight` does not appear to work with polybar's xbacklight module,
but it's possible to use the backlight module instead (by setting the card).

### Locking

One can use `i3lock` for screen locking and `xautolock` to auto lock after some
period of inactivity.

My 'lock.sh' script also uses `scrot` to take a screenshot and `convert`
(`imagemagick`) to edit it.

### Audio

```
$ sudo pacman -S pulseaudio
```

Restart for pulseaudio and pactl to start working.

```
$ sudo pacman -S mpd mpc ncmpcpp
$ systemctl --user enable mpd.service
```

Note that to check status with systemctl, the `--user` flag must also be used.

### File browser

We use ranger for browsing files, and w3m for image previews.

```
$ sudo pacman -S ranger w3m
```

### Documents

We use zathura for PDFs and other documents.

```
$ sudo pacman -S zathura zathura-djvu zathura-pdf-mupdf
$ xdg-mime default org.pwmt.zathura.desktop application/pdf
```

### Text editor

I use vim for all text editing. vim-plug is used for plugins. Some useful
commands:

```
:PlugInstall // install new plugins
:PlugUpdate  // update plugins
:PlugUpgrade // upgrade vim-plug
```

## Todo

* Pip install in setup.
