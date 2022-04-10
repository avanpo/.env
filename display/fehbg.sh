#!/usr/bin/env bash

theme="${HOME}/.env/media/morning-forest.jpg"

path="${HOME}/.env/media/default.jpg"
if [ -e "${theme}" ]; then
	path="${theme}"
fi

feh --no-fehbg --bg-fill "${path}"
wal -i "${path}"
echo "fehbg.sh: Set background and generated theme from ${path} ."
