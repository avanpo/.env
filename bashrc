[[ $- != *i* ]] && return

# settings

HISTCONTROL=ignoreboth
HISTSIZE=10000
shopt -s histappend

set -o vi
export EDITOR='vim'
export VISUAL='vim'

export PAGER="less -RS"
export LESSHISTFILE=/dev/null

# path

export PATH="$PATH:~/.env/bin"

# PS1

RST="\[\e[m\]"
BOLD="\[\e[1m\]"
GRN="\[\e[32m\]"
BLUE="\[\e[34m\]"

HOST="\h"
if [[ "$SSH_CLIENT" ]]; then
	HOST=$BLUE$HOST
fi

PS1=$BOLD$GRN'\u@'$HOST$RST':'$BOLD$BLUE'\w'$RST'\$ '

# aliases

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias less='less -RS'

alias l='ls -lah'
alias la='ls -a'
alias ll='l --color=always | less'

alias q='exit'
alias ps='ps -efjH'
alias psg='ps | grep'
alias c='xclip -selection clipboard'

alias ..='cd ..'
alias ...='cd ../..'

alias vi='vim'
alias o='xdg-open'
alias vpn='sudo openvpn --config ~/.config/client.ovpn'

alias diskspace='df -h'
alias dirspace='du -sh *'

# functions

# DESCRIPTION
#   Get directory information. Does not include hidden directories or files,
#   but could easily be modified to do so by setting GLOBIGNORE.
dirinfo() {
	df -h . | sed -n 2p | awk '{print "Partition usage:", $3, "of", $2}'
	len=$(ls -a | awk '{print length}' | sort -rn | head -1)

	dir_space=$(du -sh . | awk '{print $1}')
	dir_files=$(find . -type f -printf '\n' | wc -l)
	printf "%-5s \033[34;1m%-${len}s\033[0m  %d\n" "$dir_space" "." "$dir_files"

	for path in *; do
		name=$(basename "$path")
		if [ -d "$path" ]; then
			space=$(du -sh "$path" | awk '{print $1}')
			num_files=$(find  "$path" -type f -printf '\n' | wc -l)
			printf "%-5s \033[34;1m%-${len}s\033[0m  %d\n" "$space" "$name" "$num_files"
		else
			space=$(stat --printf="%s\n" "$path" | numfmt --to=si)
			printf "%-5s %-${len}s\n" "$space" "$name"
		fi
	done
}

# SYNOPSIS
#   manopt command opt
#
# DESCRIPTION
#   Returns the portion of COMMAND's man page describing option OPT.
#   Note: Result is plain text - formatting is lost.
#
#   OPT may be a short option (e.g., -F) or long option (e.g., --fixed-strings);
#   specifying the preceding '-' or '--' is OPTIONAL - UNLESS with long option
#   names preceded only by *1* '-', such as the actions for the `find` command.
#
#   Matching is exact by default; to turn on prefix matching for long options,
#   quote the prefix and append '.*', e.g.: `manopt find '-exec.*'` finds
#   both '-exec' and 'execdir'.
#
# EXAMPLES
#   manopt ls l           # same as: manopt ls -l
#   manopt sort reverse   # same as: manopt sort --reverse
#   manopt find -print    # MUST prefix with '-' here.
#   manopt find '-exec.*' # find options *starting* with '-exec'
manopt() {
	local cmd=$1 opt=$2
	[[ $opt == -* ]] || { (( ${#opt} == 1 )) && opt="-$opt" || opt="--$opt"; }
	man "$cmd" | col -b | awk -v opt="$opt" -v RS= '$0 ~ "(^|,)[[:blank:]]+" opt "([[:punct:][:space:]]|$)"'
}

# DESCRIPTION
#   Print out the colors defined in .Xresources.
colors() {
	echo -e "\033[0mNO_COLOR"
	echo -e "\033[0;30mBLACK  \t\t\033[1;30mLIGHT_BLACK"
	echo -e "\033[0;31mRED    \t\t\033[1;31mLIGHT_RED"
	echo -e "\033[0;32mGREEN  \t\t\033[1;32mLIGHT_GREEN"
	echo -e "\033[0;33mYELLOW \t\t\033[1;33mLIGHT_YELLOW"
	echo -e "\033[0;34mBLUE   \t\t\033[1;34mLIGHT_BLUE"
	echo -e "\033[0;35mMAGENTA\t\t\033[1;35mLIGHT_MAGENTA"
	echo -e "\033[0;36mCYAN   \t\t\033[1;36mLIGHT_CYAN"
	echo -e "\033[0;37mGREY   \t\t\033[1;37mWHITE"
}

# networking
rping() { fping -g $1 | grep alive; }

# conversion
d2x() { echo "obase=16;${1}" | bc | awk '{print tolower($0)}'; }
d2b() { echo "obase=2;${1}" | bc; }
x2d() { echo "ibase=16;${1^^}" | bc; }
x2b() { echo "ibase=16;obase=2;${1^^}" | bc; }
b2d() { echo "ibase=2;${1}" | bc; }
b2x() { echo "ibase=2;obase=10000;${1}" | bc | awk '{print tolower($0)}'; }

# source machine specific config

[[ -f "$HOME/.config/bashrc" ]] && . "$HOME/.config/bashrc"
