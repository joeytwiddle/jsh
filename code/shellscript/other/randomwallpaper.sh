#!/bin/bash

# If we don't have imagemagick's convert, then the ATTEMPT loop below will perceive a failure from jxsetbg and will keep retrying.
. require_exes convert

## This was previously /bin/zsh but that had a problem.  Somehow in the
## following line, find interpreted $WALLPAPERDIRS as one argument.
# memo -t "2 weeks" find $WALLPAPERDIRS -name "noshow" |

# FAST=1                # Does not scale up to desktop, just blits to background.
# PREVIEW_WALLPAPER=1   # Does not preview - scales before drawing anything.

## TODO: Randomwallpaper is really quite slow.  But we can fix this.  Have it pre-cache an image (or a few)!

if [ "$1" = -gl ]
then
	## Gentle panning gives me motion sickness, but it's here if you want it:
	# /usr/lib/xscreensaver/glslideshow -titles -root -duration 20 -zoom 80 -pan 20 -fade 10

	## No panning is much more CPU-efficient.
	## But with no panning, the background does not get updated when Fluxbox switches desktop!
	## We would be better off running randomwallpaper in a loop instead of using glslideshow.  Although it wouldn't do the fading.
	# /usr/lib/xscreensaver/glslideshow -titles -root -duration 20 -zoom 100 -fade 5

	## So, at least for Fluxbox, we need a little panning, even though it is constantly using CPU.
	## But the panning is often visible, because there is lots of space for panning when the image ratio does not match the screen ratio.  So to reduce motion sickness, we slow it down more.
	/usr/lib/xscreensaver/glslideshow -titles -root -duration 600 -zoom 99 -pan 600 -fade 5

	exit
fi

[ -n "$DONT_DARKEN" ] || DARKEN=true

## Usage: randomwallpaper [ <path>s ]* [ <regexp_for_grep> ]

## TODO: skip images below a certain size (pixelswise or bytewise)

while [ -n "$*" ]
do [ -d "$1" ] && WALLPAPERDIRS="$WALLPAPERDIRS $1" && shift || break
done
# [ -z "$WALLPAPERDIRS" ] && WALLPAPERDIRS="/stuff/wallpapers/ /stuff/mirrors/www.irtc.org/ $HOME/Wallpapers/" # /stuff/mirrors/" # /www/uploads/"
[ -z "$WALLPAPERDIRS" ] && WALLPAPERDIRS="$HOME/Wallpapers/"



cd / # just for memoing

LASTWALL=`justlinks /tmp/randomwallpaper-last`
if [ -n "$LASTWALL" ]
then
	# while true
	# do
		# LW2=`justlinks "$LASTWALL"`
		# if [ -n "$LW2" ]
		# then LASTWALL="$LW2"
		# else break
		# fi
	# done
	# jshinfo "Last wallpaper was: $LASTWALL"
	jshinfo "If you didn't like the last wallpaper: del '$LASTWALL'"
fi

for ATTEMPT in `seq 1 20`
do

	FILETYPES="jpg jpeg gif bmp pcx lbm ppm png pgm pnm tga tif tiff xbm xpm tif gf xcf aa cel fits fli gbr gicon hrz pat pix sgi sunras xwd"
	SEARCHARGS=' -iname "*.'` echo "$FILETYPES" | sed 's+ +" -or -iname "*.+g' `'"'
	## And if we want to catch them.gz too:
	SEARCHARGS="$SEARCHARGS"" -or -iname \"*."` echo "$FILETYPES" | sed 's+ +.gz" -or -iname "*.+g' `".gz\""

	AVOID="thumbnails"

	# find . -type f -and -not -name "*.html" > tmp.txt
	# FILE=`chooserandomline tmp.txt`

	SPECIALISE="$1"
	[ -n "$SPECIALISE" ] && shift

	# Folders containing the noshow file, and their subfolders, are to be
	# ignored.  To achieve this we build an UNGREPEXPR.
	if [ "$1" = -all ]
	then
		UNGREPEXPR='^$'
	else
		## For greater efficiency: put this whole block in a fn, then memo a call to the fn
		UNGREPEXPR="\("`
			memo -t "2 weeks" find $WALLPAPERDIRS -name "noshow" |
			toregexp |
			while read X
			do echo '^'\`dirname "$X"\`'/|'
			done |
			tr -d '\n' |
			sed 's+|$++'
		`"\)"
		if [ -z "$UNGREPEXPR" ] || [ "$UNGREPEXPR" = "\(\)" ]
		then UNGREPEXPR="^$"
		else [ -n "$DEBUG" ] && debug "UNGREPEXPR=$UNGREPEXPR"
		fi
	fi

	## Ditto optimisation recommended above
	[ -n "$DEBUG" ] && debug "Running: find $WALLPAPERDIRS $SEARCHARGS | egrep -v \"$UNGREPEXPR\""
	# FILE=`
		# echo "memo -t '1 hour' find $WALLPAPERDIRS $SEARCHARGS" | sh |
		# egrep -v "$UNGREPEXPR" |
		# notindir $AVOID |
		# if [ -n "$SPECIALISE" ]
		# then grep "$SPECIALISE"
		# else cat
		# fi |
		# chooserandomline
	# `
		# memo -t '1 hour' verbosely find $WALLPAPERDIRS $SEARCHARGS | ## Had problems when I introduced ""s into SEARCHARGS
		memo -t '1 hour' eval "find $WALLPAPERDIRS $SEARCHARGS" |
		egrep -v "$UNGREPEXPR" |
		notindir $AVOID |
		if [ -n "$SPECIALISE" ]
		then grep "$SPECIALISE"
		else cat
		fi > /tmp/possible_wallpapers.list
	FILE=`
		chooserandomline /tmp/possible_wallpapers.list
	`

	## If it's a gz, unzip it.  TODO: zip it up again after!
	if endswith "$FILE" "\.gz"
	then
		gunzip "$FILE"
		FILE=`echo "$FILE" | beforelast "\.gz"`
	fi

	## Get image area by extracting dimensions
	IMAGESIZE=`imagesize "$FILE" | grep "^[0-9]*x[0-9]*" | sed 's+x+ * +'`
	if [ -n "$IMAGESIZE" ]
	then
		## For zsh: AREA=`noglob expr $IMAGESIZE`
		##          AREA=`noglob calc $IMAGESIZE`
		AREA=`echo "$IMAGESIZE" | bc`
	fi

	if [ -f "$FILE" ] && file "$FILE" | egrep "image|bitmap" > /dev/null && [ `filesize "$FILE"` -gt 10000 ] && [ -n "$AREA" ] && [ "$AREA" -gt 102030 ]
	then
		echo "del \"$FILE\""
		ln -sf "$FILE" /tmp/randomwallpaper-last

		## There are two situations when we must process the wallpaper
		## 1) if we want to gamme-darken the image - user likes dark wallpaper, but with full range
		## 2) we don't have a root image setter for X which will scale the image - we need to scale the image up to X resolution ourselves.
		## ATM neither of these work.  :P
		## Also, conversion is slow!  memoing won't really work (just double the size of DB!)  But if the created image file is significantly smaller than the original, let's replace the original by our new version!  We should only do this e.g. if we are converting from 1280x1024 bitmap to 1280x1024 png, and not doing any pixel value processing.

		[ -n "$PREVIEW_WALLPAPER" ] && xsetbg "$FILE"   ## Preview
		[ -n "$FAST" ] && break
		(
			# Ideally we would use a PNG instead of JPG, but it takes significantly longer (even with 0% compression), and with quality 100% JPG is indistinguishable to the eye, even on vector images.
			# Curiously, JPG is still faster on vector images, even though it produces a larger image file.
			MODDED_FILE="$HOME/j/background1.modulated.jpg"
			## Darken image: bri,sat,hue
			# [ -n "$DARKEN" ] && which convert >/dev/null 2>&1 &&
			# MODULATE="-modulate 80,100,100" ## This mucks up colours nastily (more red?  quantised?)
			if which convert>/dev/null 2>&1 && verbosely convert "$FILE" -auto-orient $MODULATE -quality 100% "$MODDED_FILE"
			then
				ORIGINAL_SIZE=$(filesize "$FILE")
				NEW_SIZE=$(filesize "$MODDED_FILE")
				SIZECHANGE=$((100*(ORIGINAL_SIZE-NEW_SIZE)/ORIGINAL_SIZE))
				jshinfo "Modulation caused $SIZECHANGE% shrinking."
				ln -sf "$MODDED_FILE" "$JPATH/background1.jpg"
			else
				jshwarn "Modulation of image failed.  Just linking original."
				verbosely ln -sf "$FILE" "$JPATH/background1.jpg"
			fi
		) &&
		jxsetbg "$JPATH/background1.jpg" ||
		jxsetbg "$FILE"
		# if fadebg "$JPATH/background1.jpg" "$FILE"
		# else
			# jshwarn "fadebg failed on $FILE"
		# fi
		[ "$?" = 0 ] && break
	else
		jshwarn "Wallpaper $FILE does not exist or is not an image or is too small!"
	fi

	# Black and white with xsetroot
	# TEMPFILE="$JPATH/tmp/currentwallpaper.xbm"
	# convert "$FILE" $TEMPFILE
	# xsetroot -bitmap $TEMPFILE

done
