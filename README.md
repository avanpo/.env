# env

my linux setup. at home, this is arch. a work in progress

* wm: i3
* bar: polybar
* lock: xautolock, i3lock
* composite manager: compton
* terminal: urxvt
* app launcher: rofi
* image viewer: feh
* pdf viewer: zathura

### installation

WARNING: this will overwrite any existing dotfiles, so back them up first.

```shell
cd ~
git clone https://github.com/avanpo/.env.git
./.env/setup.sh

# or if setting up a server...
# ./.env/setup_server.sh
```

installing to `~/.env` is required, all configs assume this to be the location of scripts and various media.

### configuration

all configuration custom to a machine should go into a file located at `~/.config/bashrc`. this file is sourced at the end of `~/.bashrc`.

for local machine installed using `setup.sh`, this file should contain the following environment variable:

```
export SETUP=laptop
```

optional vars:

```
# for the polybar weather script
export OPENWEATHERMAP_LOCATION=city
export OPENWEATHERMAP_API_KEY=key
```
