#!/bin/sh

cd $JPATH/wallpapers

# find . -type f -and -not -name "*.html" > tmp.txt
export INBADDIR=false
UNGREPEXPR=`find . -name "noshow" | while read X; do
  echo "^"\`dirname "$X"\`"|"
done | tr -d "\n" | sed "s+|$++"`

# FILE=`chooserandomline tmp.txt`

FILE=`find . -type f -and -not -name "*.html" | egrep -v "/tiles/|/small/" | egrep -v "$UNGREPEXPR" | chooserandomline`
# echo "$FILE"

if test -f "$FILE" && file "$FILE" | egrep "image|bitmap" > /dev/null; then
  xv -root -rmode 5 -maxpect -quit "$FILE" &
  ln -sf "$PWD/$FILE" "$JPATH/background1.jpg" &
else
  echo "Wallpaper $FILE does not exist or is not an image!"
  randomwallpaper
fi

# Black and white with xsetroot
# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
# convert "$FILE" $TEMPFILE
# xsetroot -bitmap $TEMPFILE
