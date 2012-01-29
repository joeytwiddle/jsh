#!/bin/sh
## TODO: merge volumeup and volumedown into adjustvolume +/-N
## TODO CONSIDER: some systems will want us to only change one mixer,
##   i.e. the first card's master might control all cards?

killall osd_cat 2>/dev/null

HOWMUCH="$1"
if test ! $HOWMUCH; then
	HOWMUCH=10
fi

HEAD=""

for MIXER in /dev/mixer*
do

	VOL=`get_volume`
	VOL=`expr $VOL + $HOWMUCH`

	# jshinfo "Changing $MIXER to $VOL"
	set_volume "$VOL"

	VOL=`get_volume`

	[ "$VOL" ] || VOL=25
	REPCHARS=$((VOL*72/100))
	echo "$HEAD[`strrep = $REPCHARS`[$VOL%]`strrep - $((72-REPCHARS))`]" | osd_cat -A right -c green -d 1 -f '-*-fixed-*-r-*-*-*-180-*-*-*-*-*-*' &
	## I was using freemono but it wasn't available on all systems.

	HEAD="$HEAD
"

done

