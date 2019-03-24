#!/bin/sh
xprop -root | grep NET_AC | grep -E -o '0x[0-9a-f]+'
