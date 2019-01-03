#!/bin/sh

# merge in resources and run scripts

userresources=$HOME/.Xresources

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# x settings
xset -b
xsetroot -solid "#000000"

# set background
$HOME/.env/display/fehbg.sh

# start urxvtd
urxvtd -q -f -o

# set up env
exec i3
