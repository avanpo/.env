#!/bin/bash

# Source machine specific config in case window manager hasn't done this yet.
# This is a hack. Ideally .xsession would source .bashrc, but I ran into some
# strange bugs.
source $HOME/.config/bashrc

# Terminate already running bar instances.
killall -q polybar

today="$(date '+%Y-%m-%d')"
log_file="/tmp/polybar.$today.log"

# Get network interfaces. For wired, take the last interface if there are
# multiple. Some USB to Ethernet adaptors create their own.
wireless=""
if command -v iwctl &> /dev/null; then
	wireless="$(iwctl device list | grep station | head -1 | awk '{print $2}')"
elif command -v nmcli &> /dev/null; then
	wireless="$(nmcli d status | grep wifi | grep -v disconnected | head -1 | cut -d ' ' -f 1)"
fi
wired="$(ip link show | awk -F: '$0 !~ "lo|vir|wl|tun|docker|^[^0-9]"{print $2}' | tail -1 | xargs)"
echo "launch.sh: Got wireless '$wireless' and wired '$wired' network interfaces." | tee -a "$log_file"

# Get backlight card.
backlight="$(basename "$(find /sys/class/backlight/ -mindepth 1 -print -quit)")"
echo "launch.sh: Got backlight card '$backlight'." | tee -a "$log_file"

# Wait until the processes have been shut down.
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch bar(s)
for m in $(polybar --list-monitors | cut -d":" -f1); do
	MONITOR="$m" WIRELESS_INTERFACE="$wireless" WIRED_INTERFACE="$wired" BACKLIGHT="$backlight" polybar main -c "~/.config/polybar/config.ini" 2>> "$log_file" &
	echo "launch.sh Launched polybar on $m". | tee -a "$log_file"
done

echo "launch.sh: Script exiting." | tee -a "$log_file"
