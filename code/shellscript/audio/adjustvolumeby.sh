#!/bin/sh

DELTA="$1"

# DELTA can be 1 or -1 or 10 or -10 but never +1 or +10 because they do not work through expr.

## DONE: merge volumeup and volumedown into adjustvolume +/-N
## TODO CONSIDER: some systems will want us to only change one mixer,
##   i.e. the first card's master might control all cards?

killall osd_cat 2>/dev/null

export SHOWVOLUME_HEAD=""

#for MIXER in /dev/mixer*
for MIXER in /dev/mixer
do

	VOL=`get_volume`
	VOL=`expr $VOL + $DELTA`

	# jshinfo "Changing $MIXER to $VOL"
	set_volume "$VOL"

	## This is now done by set_volume
	# [ -n "$SHOW_VOLUME" ] && show_volume

	SHOWVOLUME_HEAD="$SHOWVOLUME_HEAD
"

done


