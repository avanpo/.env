#!/bin/bash

# Exit if not a laptop setup.

if [ "$SETUP" != "laptop" ]; then
	exit 0
fi

# Automatically detects external monitors and places them to the right of
# the laptop screen.

laptop=eDP1
external=

while true
do
	current="$(xrandr | grep ' connected' | grep -v "$laptop" | awk '{print $1;}')"

	if [ -z "$current" ] && [ ! -z "$external" ]; then
		# external monitor disconnected
		xrandr --output "$external" --off
		external=
		i3-msg restart
	elif [ ! -z "$current" ] && [ "$current" != "$external" ]; then
		# new external monitor discovered
		xrandr --output "$current" --auto --right-of "$laptop"
		external="$current"
		i3-msg restart
	fi

	sleep 2
done
