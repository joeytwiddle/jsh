#!/bin/sh

export COLUMNS

popup() {
	# We renice both the xterm and the monitor program, as both can cause significant processor usage on slow systems (e.g. software rendering X).
	nice -n 5 env COLUMNS="$columns" xterm -bg "$color" -geometry "$columns"x"$rows"+"$pos" -e "$@" &
	sleep 1
}

color='#330000' columns=140 rows=28 pos=5+5      popup top   -d 4 -n 25
color='#000033' columns=100 rows=28 pos=5+375    popup sudo iotop -d 5 -n 20 -a -o
color='#003e00' columns=80  rows=28 pos=445+492  popup atop     4    25

## iotop is sudo because:
# Netlink error: Operation not permitted (1)
# iotop requires root or the NET_ADMIN capability.

## This one disabled because it lacks auto-quit (iterations) option
# color='#333e00' columns=80  rows=41 pos=700+375 popup traffic_shaping_monitor

## Green should be the brightest color, but on my monitor it needs a little boost!

