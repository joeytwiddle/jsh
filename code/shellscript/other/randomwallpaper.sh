#!/bin/sh

# cd $JPATH/wallpapers
cd /stuff/wallpapers

# find . -type f -and -not -name "*.html" > tmp.txt
# FILE=`chooserandomline tmp.txt`

SPECIALISE="$1"
if test "$SPECIALISE"; then
	shift
fi

if test "$1" = "-all"; then
	UNGREPEXPR='^$'
else
	UNGREPEXPR=`
		find . -name "noshow" |
		while read X; do
		echo '^'\`dirname "$X"\`'|'
		done |
		tr -d '\n' |
		sed 's+|$++'
	`
fi

FILE=`
	find . -type f -and -not -name "*.html" |
	egrep -v "$UNGREPEXPR" |
	if test $SPECIALISE; then
		grep "$SPECIALISE"
	else
		cat
	fi |
	chooserandomline
`
# echo "$FILE"

if test -f "$FILE" && file "$FILE" | egrep "image|bitmap" > /dev/null; then
  echo "$PWD$FILE"
  ln -sf "$PWD/$FILE" "$JPATH/background1.jpg"
  xv -root -rmode 5 -maxpect -quit "$FILE" 1>&2 ||
  xsetroot -bitmap "$FILE" 1>&2 &
else
  echo "Wallpaper $FILE does not exist or is not an image!"
  # Dangerous!
  randomwallpaper
fi

# Black and white with xsetroot
# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
# convert "$FILE" $TEMPFILE
# xsetroot -bitmap $TEMPFILE
