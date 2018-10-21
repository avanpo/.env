#!/bin/bash

distro=$(cat /etc/os-release |& grep '^ID=' | cut -d '=' -f 2)

# link dotfiles

linkdf() {
	rm .$1 2> /dev/null
	ln -s ~/.env/$1 .$1
}

linkdf bash_profile
linkdf bashrc

linkdf vimrc
linkdf gdbinit

# install software

if [[ "$distro" == "ubuntu" ]]; then
	sudo apt update && sudo apt upgrade

	# workflow
	sudo apt install -y gvim git
	# networking
	sudo apt install -y nmap traceroute fping tcpdump
fi
