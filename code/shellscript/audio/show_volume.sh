#!/bin/sh

VOL=`get_volume`

max_volume=$(amixer sget Master | grep Limits | afterlast ' ')
VOL=$(expr $VOL '*' 100 / $max_volume)

[ -n "$VOL" ] || VOL=25

WIDTH_OF_BAR=20

CHARS_ON_LEFT=$((VOL * WIDTH_OF_BAR / 100))
CHARS_ON_RIGHT=$((WIDTH_OF_BAR - CHARS_ON_LEFT))

if [ "$VOL" -lt 10 ]
then CHARS_ON_RIGHT=$((CHARS_ON_RIGHT + 1))
fi
if [ "$VOL" -gt 99 ]
then CHARS_ON_LEFT=$((CHARS_ON_LEFT - 1))
fi

# I was using freemono but it wasn't available on all systems.
outline=4
font='-*-fixed-*-r-*-*-*-320-*-*-*-*-*-*'
outline=4
font='-*-terminus-*-*-*-*-48-*-*-*-*-*-*-*'
outline=6
font='-*-helvetica-medium-r-*-*-50-*-*-*-*-*-*-*'
font='-*-lucida-medium-r-*-*-50-*-*-*-*-*-*-*'
outline=8
font='-*-lucidatypewriter-medium-r-*-*-48-*-*-*-*-*-*-*'

str="$SHOWVOLUME_HEAD|$(strrep '=' $CHARS_ON_LEFT) "$VOL" $(strrep '-' $CHARS_ON_RIGHT)|"

killall osd_cat 2>/dev/null

echo "${str}" | osd_cat -A right -c '#00ff00' -O "$outline" -o 12 -d 1 -f "$font" &

