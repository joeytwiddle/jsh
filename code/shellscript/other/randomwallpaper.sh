#!/bin/sh

# cd $JPATH/wallpapers
WALLPAPERDIRS="/stuff/wallpapers/ /stuff/mirrors/ /www/uploads/"

FILETYPES="jpg Jpeg jpeg JPG JPEG gif GIF bmp BMP pcx PCX lbm ppm png pgm pnm tga tif tiff xbm xpm tif gf xcf aa cel fits fli gbr gicon hrz pat pix sgi sunras xwd"
SEARCHARGS='-name "*.'`echo "$FILETYPES" | sed 's+ +" -or -name "*.+g'`'"'

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
		find $WALLPAPERDIRS -name "noshow" |
		while read X; do
		echo '^'\`dirname "$X"\`'|'
		done |
		tr -d '\n' |
		sed 's+|$++'
	`
fi

FILE=`
	echo "find $WALLPAPERDIRS $SEARCHARGS" | sh |
	egrep -v "$UNGREPEXPR" |
	if test $SPECIALISE; then
		grep "$SPECIALISE"
	else
		cat
	fi |
	chooserandomline
`
if test -f "$FILE" && file "$FILE" | egrep "image|bitmap" > /dev/null; then
  echo "del \"$FILE\""
  ln -sf "$FILE" "$JPATH/background1.jpg"
  xsetbg "$FILE"
else
  echo "Wallpaper $FILE does not exist or is not an image!"
  # Dangerous!
  randomwallpaper
fi

# Black and white with xsetroot
# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
# convert "$FILE" $TEMPFILE
# xsetroot -bitmap $TEMPFILE
