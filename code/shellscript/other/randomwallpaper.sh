#!/bin/sh

## Usage: randomwallpaper [ <path>s ]* [ <regexp_for_grep> ]

## TODO: skip images below a certain size (pixelswise or bytewise)

while [ "$*" ]
do [ -d "$1" ] && WALLPAPERDIRS="$WALLPAPERDIRS $1" && shift || break
done
[ "$WALLPAPERDIRS" ] || WALLPAPERDIRS="/stuff/wallpapers/" # /stuff/mirrors/" # /www/uploads/"

cd / # just for memoing

for ATTEMPT in `seq 1 20`
do

	FILETYPES="jpg jpeg gif bmp pcx lbm ppm png pgm pnm tga tif tiff xbm xpm tif gf xcf aa cel fits fli gbr gicon hrz pat pix sgi sunras xwd"
	SEARCHARGS=' -iname "*.'` echo "$FILETYPES" | sed 's+ +" -or -iname "*.+g' `'"'
	## And if we want to catch them.gz too:
	SEARCHARGS="$SEARCHARGS"' -or -iname "*.'` echo "$FILETYPES" | sed 's+ +.gz" -or -iname "*.+g' `'.gz"'

	AVOID="thumbnails"

	# find . -type f -and -not -name "*.html" > tmp.txt
	# FILE=`chooserandomline tmp.txt`

	SPECIALISE="$1"
	[ "$SPECIALISE" ] && shift

	if [ "$1" = -all ]
	then
		UNGREPEXPR='^$'
	else
		## For greater efficiency: put this whole block in a fn, then memo a call to the fn
		UNGREPEXPR=`
			memo -t "1 hour" find $WALLPAPERDIRS -name "noshow" |
			while read X
			do echo '^'\`dirname "$X"\`'|'
			done |
			tr -d '\n' |
			sed 's+|$++'
		`
		if [ "$UNGREPEXPR" = "" ]
		then UNGREPEXPR="^$"
		fi
	fi

	## Ditto optimisation recommended above
	[ "$DEBUG" ] && debug "Running: find $WALLPAPERDIRS $SEARCHARGS | egrep -v \"$UNGREPEXPR\""
	FILE=`
		echo "memo -t '1 hour' find $WALLPAPERDIRS $SEARCHARGS" | sh |
		egrep -v "$UNGREPEXPR" |
		notindir $AVOID |
		if [ "$SPECIALISE" ]
		then grep "$SPECIALISE"
		else cat
		fi |
		chooserandomline
	`

	## If it's a gz, unzip it.  TODO: zip it up again after!
	if endswith "$FILE" "\.gz"
	then
		gunzip "$FILE"
		FILE=`echo "$FILE" | beforelast "\.gz"`
	fi

	if [ -f "$FILE" ] && file "$FILE" | egrep "image|bitmap" > /dev/null && [ `filesize "$FILE"` -gt 10000 ]
	then
		echo "del \"$FILE\""
		ln -sf "$FILE" "$JPATH/background1.jpg"
		jxsetbg "$FILE" && break || jshwarn "jxsetbg failed."
	else
		jshwarn "Wallpaper $FILE does not exist or is not an image or is too small!"
	fi

	# Black and white with xsetroot
	# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
	# convert "$FILE" $TEMPFILE
	# xsetroot -bitmap $TEMPFILE

done
