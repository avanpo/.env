#!/bin/bash
#
# Automatically detects external monitors and places them to the right of
# the laptop screen.
#

# Exit if not a laptop setup.
if [ "$SETUP" != "laptop" ]; then
	echo "outputs.sh: Exiting; not a laptop setup."
	exit 0
fi

laptop=eDP1
external=

echo "output.sh: Starting xrandr loop."

while true
do
	current="$(xrandr | grep ' connected' | grep -v "$laptop" | awk '{print $1;}')"

	if [ -z "$current" ] && [ ! -z "$external" ]; then
		# external monitor disconnected
		xrandr --output "$external" --off
		external=
		i3-msg restart
		echo "output.sh: External monitor disconnected."
	elif [ ! -z "$current" ] && [ "$current" != "$external" ]; then
		# new external monitor discovered
		xrandr --output "$current" --auto --right-of "$laptop"
		external="$current"
		i3-msg restart
		echo "output.sh: External monitor discovered."
	fi

	sleep 2
done

echo "output.sh: Exiting."
