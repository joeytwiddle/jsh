#!/bin/sh

cd / # just for memoing

REPEAT=once

while test "$REPEAT"
do

	REPEAT=

	# cd $JPATH/wallpapers
	WALLPAPERDIRS="/stuff/wallpapers/ /stuff/mirrors/" # /www/uploads/"

	FILETYPES="jpg Jpeg jpeg JPG JPEG gif GIF bmp BMP pcx PCX lbm ppm png pgm pnm tga tif tiff xbm xpm tif gf xcf aa cel fits fli gbr gicon hrz pat pix sgi sunras xwd"
	SEARCHARGS='-name "*.'`echo "$FILETYPES" | sed 's+ +" -or -name "*.+g'`'"'

	AVOID="thumbnails"

	# find . -type f -and -not -name "*.html" > tmp.txt
	# FILE=`chooserandomline tmp.txt`

	SPECIALISE="$1"
	if test "$SPECIALISE"
	then shift
	fi

	if test "$1" = "-all"
	then
		UNGREPEXPR='^$'
	else
		## For greater efficiency: put this whole block in a fn, then memo a call to the fn
		UNGREPEXPR=`
			memo find $WALLPAPERDIRS -name "noshow" |
			while read X
			do echo '^'\`dirname "$X"\`'|'
			done |
			tr -d '\n' |
			sed 's+|$++'
		`
	fi

	## Ditto optimisation recommended above
	FILE=`
		echo "memo find $WALLPAPERDIRS $SEARCHARGS" | sh |
		egrep -v "$UNGREPEXPR" |
		notindir $AVOID |
		if test $SPECIALISE
		then grep "$SPECIALISE"
		else cat
		fi |
		chooserandomline
	`
	if test -f "$FILE" && file "$FILE" | egrep "image|bitmap" > /dev/null
	then
		echo "del \"$FILE\""
		ln -sf "$FILE" "$JPATH/background1.jpg"
		xsetbg "$FILE" || REPEAT=true
	else
		echo "Wallpaper $FILE does not exist or is not an image!"
		## Dangerous!
		# randomwallpaper
		REPEAT=true
	fi

	# Black and white with xsetroot
	# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
	# convert "$FILE" $TEMPFILE
	# xsetroot -bitmap $TEMPFILE

done
