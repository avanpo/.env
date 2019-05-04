#!/usr/bin/env bash
#
# Run with "desktop" as the second argument to install desktop stuff.

# install software

if command -v pacman >/dev/null 2>&1; then
	sudo pacman -Syu
	sudo pacman -S --noconfirm base-devel
	sudo pacman -S --noconfirm ltrace gdb git gvim strace
	# utilities
	sudo pacman -S --noconfirm fping nmap rsync tcpdump traceroute units
	# arch specific
	if [[ $1 == desktop ]]; then
		# desktop environment
		sudo pacman -S --noconfirm compton feh htop i3 i3lock ranger rofi scrot ttf-dejavu ttf-font-awesome xautolock xbacklight
		# software
		sudo pacman -S --noconfirm firefox keepassx2 irssi transmission
		# media
		sudo pacman -S --noconfirm beep ffmpeg gimp mpc mpd mpv ncmpcpp zathura
		# extra networking
		sudo pacman -S --noconfirm openvpn bluez bluez-utils wireshark-cli
		sudo gpasswd -a "$USER" wireshark
		# embedded
		sudo pacman -S --noconfirm avr-binutils avr-gcc avrdude avr-libc
	fi
elif command -v apt >/dev/null 2>&1; then
	sudo apt update && sudo apt upgrade
	sudo apt install -y ltrace gdb git gvim strace
	sudo apt install -y fping nmap tcpdump traceroute units
	if [[ $1 == desktop ]]; then
		sudo apt install -y compton feh htop i3-wm i3lock ranger rofi scrot ttf-dejavu fonts-font-awesome xautolock xbacklight
		sudo apt install -y firefox keepassx2 irssi transmission
		sudo apt install -y beep ffmpeg gimp mpc mpd mpv ncmpcpp zathura
	fi
fi

# create folders

if [[ $1 == desktop ]]; then
	mkdir -p downloads
	mkdir -p music

	mkdir -p .config/i3
	mkdir -p .config/gtk-3.0
	mkdir -p .config/mpd/playlists
	mkdir -p .config/polybar
	mkdir -p .config/rofi
	mkdir -p .config/zathura
fi

# link dotfiles

linkdf() {
	rm .$1 2> /dev/null
	ln -s ~/.env/$1 .$1
}

if [[ $1 == desktop ]]; then
	linkdf xinitrc
	linkdf xsession
	linkdf Xresources
fi

linkdf bash_profile
linkdf bash_logout
linkdf bashrc
linkdf editrc
linkdf inputrc

linkdf vimrc
linkdf gdbinit

# link various configs

linkcf() {
	rm .config/$1 2> /dev/null
	ln -s ~/.env/$1 .config/$1
}

if [[ $1 == desktop ]]; then
	linkcf i3/config
	linkcf gtk-3.0/settings.ini
	linkcf mpd/mpd.conf
	linkcf polybar/config
	linkcf rofi/config
	linkcf zathura/zathurarc
fi
