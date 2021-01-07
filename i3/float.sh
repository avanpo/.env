#!/usr/bin/env bash
#
# Toggle ncmpcpp in a fresh terminal.

if pgrep -x "$1" > /dev/null; then
	killall "$1"
	exit 0
fi

urxvt -name cover -e "$1" &
