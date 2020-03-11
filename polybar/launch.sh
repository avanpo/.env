#!/bin/bash

# Source machine specific config in case window manager hasn't done this yet.
# This is a hack. Ideally .xsession would source .bashrc, but I ran into some
# strange bugs.
source $HOME/.config/bashrc

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Get network interfaces. For wired, take the last interface if there are
# multiple. Some USB to Ethernet adaptors create their own.
wireless="$(iw dev | grep Interface | sed -n 1p | cut -d ' ' -f 2)"
wired="$(ip link show | awk -F: '$0 !~ "lo|vir|wl|tun|^[^0-9]"{print $2}' | tail -1 | xargs)"
echo "launch.sh: Found wireless ($wireless) and wired ($wired) network interfaces."

# Launch bar(s)
if type "xrandr" > /dev/null; then
	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
		MONITOR=$m WIRELESS_INTERFACE=$wireless WIRED_INTERFACE=$wired polybar main &
	done
else
	WIRELESS_INTERFACE=$wireless WIRED_INTERFACE=$wired polybar main &
fi

echo "launch.sh: Polybar launched."
