#!/bin/sh

VOL=`get_volume`

[ "$VOL" ] || VOL=25

WIDTH_OF_BAR=30

CHARS_ON_LEFT=$((VOL * WIDTH_OF_BAR / 100))
CHARS_ON_RIGHT=$((WIDTH_OF_BAR - CHARS_ON_LEFT))

killall osd_cat 2>/dev/null

echo "$SHOWVOLUME_HEAD|$(strrep '=' $CHARS_ON_LEFT)[$VOL%]$(strrep '-' $CHARS_ON_RIGHT)|" |

osd_cat -A right -c green -O 4 -o 12 -d 1 -f '-*-fixed-*-r-*-*-*-320-*-*-*-*-*-*' &
## I was using freemono but it wasn't available on all systems.

