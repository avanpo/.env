#!/usr/bin/env bash

background="$HOME/.env/media/bg.jpg"
default="$HOME/.env/media/default.jpg"

if [ -e "$background" ]; then
	feh --no-fehbg --bg-scale "$background"
else
	feh --no-fehbg --bg-scale "$default"
fi
