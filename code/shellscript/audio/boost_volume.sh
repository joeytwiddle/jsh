#!/bin/sh
# See also: pavucontrol

volume="$1"
[ -z "$volume" ] && volume="150"

pactl -- set-sink-volume 0 "$volume"%

# or +1dB or -10%
