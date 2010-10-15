#!/bin/sh
if xisrunning && test ! "$1" = "-inx"
then

	# `jwhich xterm` -geometry 43x27+989+41 +sb -sl 5000 -vb -si -sk -bg black -fg white -font '-schumacher-clean-medium-r-normal-*-*-80-*-*-c-*-iso646.1991-irv' -e "$JPATH/tools/music2"  &
	`jwhich xterm` +sb -sl 5000 -vb -si -sk -bg black -fg white -e "$JPATH/tools/music" -inx &

fi

updatemusiclist

## Renice this sh to give child mpg123 priority
TOMOD=$$
MODCOM="renice -15 -p $TOMOD"
export DISPLAY=
requestsudo "$MODCOM"

# consolemixer

# cat $JPATH/music/list.m3u | mpg123 -Z@-
jrep randommp3
