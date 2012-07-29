#!/bin/sh
# jsh-depends-ignore: wine xterm
# jsh-ext-depends: find seq wine
# jsh-depends: randomorder wineonedemo

## I think wine+demoz are more likely to work if you set wine's "window management" to "desktop" (i use 1024x768).

echo
echo "If you abort this process, you may wish to run `cursered;cursebold`slaywine`cursenorm` to reset."
echo

DEMODIRS="$DEMODIRS /stuff/software/demoz/"
[ -d "/mnt/cdrom/stuff/software/demoz/" ] && DEMODIRS="$DEMODIRS /mnt/cdrom/stuff/software/demoz/"

original_xwin_size="`getxwindimensions`"

if test "$1" = "topdown" || test "$1" = "bestfirst"; then
	for X in `seq 10 -1 0`; do
		winealldemoz "/$X/"
	done
	exit 0
fi

find $DEMODIRS -type f |
# grep "/wine/" |
# Optional:
if test "$1" = ""; then
	cat
else
	grep "$1"
fi |
# grep -v "/gl/" |
# grep "/gl/" |
randomorder |
while read X; do

	echo
	echo "Loading demo from: $X"
	echo

	# 'xterm' -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# NAME=`echo "$X" | sed 's+.*/++;s+\(.*\)\.[^\.]*$+\1+'`
	# SIZE=`du -sk "$X" | sed 's+[ 	].*++'`"k"
	# 'xterm' -title "wineonedemo: $NAME ($SIZE)" -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# /usr/bin/X11/xterm -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	wmctrl_store_positions
	wineonedemo "$X"
	xrandr -s "$original_xwin_size"
	wmctrl_restore_positions

	echo
	echo "That was: $X"
	echo
	echo
	echo
	sleep 4

done
