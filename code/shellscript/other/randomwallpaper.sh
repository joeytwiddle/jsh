#!/bin/sh

export INBADDIR=false
UNGREPEXPR=`find . -name "noshow" | while read X; do
  echo "^"\`dirname "$X"\`"|"
done | tr -d "\n" | sed "s+|$++"`

# cd $JPATH/wallpapers
# find . -type f -and -not -name "*.html" > tmp.txt
# FILE=`chooserandomline tmp.txt`

FILE=`find . -type f -and -not -name "*.html" | egrep -v "$UNGREPEXPR" | chooserandomline`
echo "$FILE"

if test -f "$FILE" && test ! "$INBADDIR" = "true"; then
  xv -root -rmode 5 -maxpect -quit "$FILE" &
  ln -sf "$PWD/$FILE" "$JPATH/background1.jpg" &
else
  echo "Wallpaper $FILE does not exist!"
  randomwallpaper
fi

# Black and white with xsetroot
# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
# convert "$FILE" $TEMPFILE
# xsetroot -bitmap $TEMPFILE
