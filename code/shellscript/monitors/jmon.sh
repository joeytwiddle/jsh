#!/bin/sh

export COLUMNS

popup() {
	nice -n 5 env COLUMNS="$columns" xterm -bg "$color" -geometry "$columns"x"$rows"+"$pos" -e "$@" &
	sleep 1
}

color='#330000' columns=160 rows=28 pos=5+5     popup top   -d 4 -n 25
color='#000033' columns=100 rows=28 pos=5+375   popup iotop -d 5 -n 20 -a -o
color='#003e00' columns=80  rows=28 pos=56x600  popup atop     4    25

## This one disabled because it lacks auto-quit (iterations) option
# color='#333e00' columns=80  rows=41 pos=700+375 popup traffic_shaping_monitor

## Green should be the brightest color, but on my monitor it needs a little boost!

