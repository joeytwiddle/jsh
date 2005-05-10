# jsh-depends-ignore: wine xterm
# jsh-ext-depends: find seq wine
# jsh-depends: randomorder wineonedemo

## I think wine+demoz are more likely to work if you set wine's "window management" to "desktop" (i use 1024x768).

DEMODIRS="$DEMODIRS /stuff/software/demoz/ /mnt/cdrom/stuff/software/demoz/"

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

	echo "$X"

	'xterm' -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# /usr/bin/X11/xterm -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# wineonedemo "$X"

done
