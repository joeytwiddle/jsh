#!/bin/sh

cd $JPATH/wallpapers
find . -type f -and -not -name "*.html" > tmp.txt
FILE=`chooserandomline tmp.txt`

if test -f "$FILE"; then
  xv -root -rmode 5 -maxpect -quit "$FILE"
else
  echo "Wallpaper $FILE does not exist!"
  randomwallpaper
fi

# Black and white with xsetroot
# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
# convert "$FILE" $TEMPFILE
# xsetroot -bitmap $TEMPFILE
