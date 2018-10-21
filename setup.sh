#!/bin/bash

distro=$(cat /etc/os-release |& grep '^ID=' | cut -d '=' -f 2)

# install software
# TODO: actually test this and add missing software

if [ "$distro" = "arch" ]; then
	# desktop environment
	#####################
	sudo pacman -S --noconfirm i3 rofi ranger compton conky xautolock
	sudo pacman -S --noconfirm scrot ttf-dejavu ttf-font-awesome

	# software
	#####################
	sudo pacman -S --noconfirm firefox keepassx2 irssi transmission

	# media
	#####################
	sudo pacman -S --noconfirm mpd mpc ncmpcpp mpv gimp zathura
	sudo pacman -S --noconfirm ffmpeg

	# tools
	#####################
	# workflow
	sudo pacman -S --noconfirm gvim git rsync
	# utilities
	sudo pacman -S --noconfirm units
	# debugging
	sudo pacman -S --noconfirm gdb ltrace strace
	# networking
	sudo pacman -S --noconfirm openvpn bluez bluez-utils
	sudo pacman -S --noconfirm nmap traceroute fping wireshark-cli tcpdump
	sudo gpasswd -a "$USER" wireshark
	# embedded
	sudo pacman -S --noconfirm avr-binutils avr-gcc avrdude avr-libc
fi

# create folders

mkdir -p downloads
mkdir -p music

mkdir -p .config/i3
mkdir -p .config/gtk-3.0
mkdir -p .config/mpd/playlists
mkdir -p .config/polybar
mkdir -p .config/rofi
mkdir -p .config/zathura

# link dotfiles

linkdf() {
	rm .$1 2> /dev/null
	ln -s ~/.env/$1 .$1
}

linkdf xinitrc
linkdf xsession
linkdf Xresources

linkdf bash_profile
linkdf bashrc

linkdf vimrc
linkdf gdbinit

# link various configs

linkcf() {
	rm .config/$1 2> /dev/null
	ln -s ~/.env/$1 .config/$1
}

linkcf i3/config
linkcf gtk-3.0/settings.ini
linkcf mpd/mpd.conf
linkcf polybar/config
linkcf rofi/config
linkcf zathura/zathurarc
