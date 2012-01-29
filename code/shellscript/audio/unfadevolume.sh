#!/bin/sh
for X in `seq 1 1 90`
do
	set_volume "$X"%   # added % for Alsa
	sleep 20   # slowly
done
