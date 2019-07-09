#!/bin/bash

# Don't lock if we have an argument "nofullscreen" and we are fullscreen.
if [[ $1 = "nofullscreen" ]]; then
	active_win_id="$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)"
	xprop -id ${active_win_id} | grep _NET_WM_STATE_FULLSCREEN && exit 0
fi

display_regex="([0-9]+)x([0-9]+)\\+([0-9]+)\\+([0-9]+)"
image_regex="([0-9]+)x([0-9]+)"

img="$HOME/.env/i3/lock.png"
lockbg="/tmp/i3lock.png"

(( $# )) && { img=$1; }

scrot "$lockbg"

lock_img_info=$(identify $img)
[[ $lock_img_info =~ $image_regex ]]
img_width=${BASH_REMATCH[1]}
img_height=${BASH_REMATCH[2]}

params=""

while read line
do
	if [[ $line =~ $display_regex ]]; then
		width=${BASH_REMATCH[1]}
		height=${BASH_REMATCH[2]}
		x=${BASH_REMATCH[3]}
		y=${BASH_REMATCH[4]}
		pos_x=$(($x+$width/2-$img_width/2))
		pos_y=$(($y+$height/2-$img_height/2))

		params="$params '$img' '-geometry' '+$pos_x+$pos_y' '-composite' '-matte' "
	fi
done <<<"$(xrandr)"

convert "$lockbg" -scale 10% -scale 1000% "$lockbg"
params="'$lockbg' $params '$lockbg'"
eval convert $params

i3lock -u -i "$lockbg"

rm $lockbg
