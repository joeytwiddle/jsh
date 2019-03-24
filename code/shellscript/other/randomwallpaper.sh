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
do
	## Previously we would use an argument as a search folder, only if that folder could be found
	## Disabled because this produced inconsistent behaviour (depending what folders are present on the filesystem)
	## (Also it would pick up relative folders, but then fail to find them because we `cd /` later)
	# [ -d "$1" ] && WALLPAPERDIRS="$WALLPAPERDIRS $1" && shift || break

	## Be explicit if we want to search a particular folder
	if [ "$1" = -dir ]
	then
		WALLPAPERDIRS="$WALLPAPERDIRS $2"
		shift
		shift
	else
		break
	fi
done

# [ -z "$WALLPAPERDIRS" ] && WALLPAPERDIRS="/stuff/wallpapers/ /stuff/mirrors/www.irtc.org/ $HOME/Wallpapers/" # /stuff/mirrors/" # /www/uploads/"
[ -z "$WALLPAPERDIRS" ] && WALLPAPERDIRS="$HOME/Wallpapers/ $HOME/Dropbox/pix/wallpapers"



cd / # just for memoing

LASTWALL=`readlink /tmp/randomwallpaper-last`
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
	jshinfo "To delete the previous wallpaper: del '$LASTWALL'"
fi

SPECIALISE="$1"
[ -n "$SPECIALISE" ] && shift

for ATTEMPT in `seq 1 20`
do

	FILETYPES="jpg jpeg gif bmp pcx lbm ppm png pgm pnm tga tif tiff xbm xpm tif gf xcf aa cel fits fli gbr gicon hrz pat pix sgi sunras xwd webp"
	SEARCHARGS=' -iname "*.'` echo "$FILETYPES" | sed 's+ +" -or -iname "*.+g' `'"'
	## And if we want to catch them.gz too:
	SEARCHARGS="$SEARCHARGS"" -or -iname \"*."` echo "$FILETYPES" | sed 's+ +.gz" -or -iname "*.+g' `".gz\""

	AVOID="thumbnails"

	# find . -type f -and -not -name "*.html" > tmp.txt
	# FILE=`chooserandomline tmp.txt`

	# Folders containing the noshow file, and their subfolders, are to be
	# ignored.  To achieve this we build an UNGREPEXPR.
	if [ "$1" = -all ]
	then
		UNGREPEXPR='^$'
	else
		## For greater efficiency: put this whole block in a fn, then memo a call to the fn
		UNGREPEXPR="("`
			memo -t "2 weeks" find $WALLPAPERDIRS -type f -name "noshow" |
			toregexp |
			while read X
			do echo '^'\`dirname "$X"\`'/|'
			done |
			tr -d '\n' |
			sed 's+|$++'
		`")"
		if [ -z "$UNGREPEXPR" ] || [ "$UNGREPEXPR" = "()" ]
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
		# then grep -i "$SPECIALISE"
		# else cat
		# fi |
		# chooserandomline
	# `
		# memo -t '1 hour' verbosely find $WALLPAPERDIRS $SEARCHARGS | ## Had problems when I introduced ""s into SEARCHARGS
		memo -t '1 hour' eval "find $WALLPAPERDIRS $SEARCHARGS" |
		egrep -v "$UNGREPEXPR" |
		notindir $AVOID |
		if [ -n "$SPECIALISE" ]
		then grep -i "$SPECIALISE"
		else cat
		fi > /tmp/possible_wallpapers.list
	FILE=`
		chooserandomline /tmp/possible_wallpapers.list
	`

	[ -n "$FILE" ] && [ -f "$FILE" ] || continue

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
		jshinfo "To delete the current  wallpaper: del '$FILE'"
		ln -sf "$FILE" /tmp/randomwallpaper-last

		## There are two situations when we must process the wallpaper
		## 1) if we want to gamme-darken the image - user likes dark wallpaper, but with full range
		## 2) we don't have a root image setter for X which will scale the image - we need to scale the image up to X resolution ourselves.
		## ATM neither of these work.  :P
		## Also, conversion is slow!  memoing won't really work (just double the size of DB!)  But if the created image file is significantly smaller than the original, let's replace the original by our new version!  We should only do this e.g. if we are converting from 1280x1024 bitmap to 1280x1024 png, and not doing any pixel value processing.

		[ -n "$PREVIEW_WALLPAPER" ] && xsetbg "$FILE"   ## Preview

		if [ -n "$FAST" ]
		then
			# Black and white with xsetroot
			#TEMPFILE="/tmp/currentwallpaper.xbm"
			#convert "$FILE" $TEMPFILE &&
			#xsetroot -bitmap $TEMPFILE &&
			#break || continue

			xsetbg "$FILE" && break || continue
		fi

		FILE_TO_USE="$FILE"

		if which convert>/dev/null 2>&1
		then
			## Darken image: bri,sat,hue
			## DISABLED because it mucks up colours weirdly, and enhances artifacts in vector images.
			# [ -n "$DARKEN" ] && MODULATE="-modulate 80,100,100"
			## Not really what we wanted to achieve
			# [ -n "$DARKEN" ] && MODULATE="-gamma 0.5"

			# Ideally we would use a PNG instead of JPG, but it takes significantly longer (even with 0% compression), and with quality 100% JPG is indistinguishable to the eye, even on vector images.
			# (Actually if I zoom in I can sometimes detect very faint ringing pixels, but these are really not noticeable when zoomed out.)
			# Curiously, JPG is still faster on vector images, even though it produces a larger image file.
			#MODDED_FILE="/tmp/background.modulated.$USER.jpg"
			# But it really makes a mess on some images (e.g. clipart-like images with transparent background), so we will use png.
			# If we still get performance issues in future, perhaps the image is very large, so we should scale it down to desktop size for better performance.
			MODDED_FILE="/tmp/background.modulated.$USER.png"

			# -background black and -flatten improve the look of partially transparent images
			verbosely convert "$FILE_TO_USE" -background black -flatten -auto-orient $MODULATE -quality 100% "$MODDED_FILE"
			if [ "$?" = 0 ]
			then
				# ORIGINAL_SIZE=$(filesize "$FILE_TO_USE")
				# NEW_SIZE=$(filesize "$MODDED_FILE")
				# SIZECHANGE=$((100*(ORIGINAL_SIZE-NEW_SIZE)/ORIGINAL_SIZE))
				# jshinfo "Modulation caused $SIZECHANGE% shrinking."

				FILE_TO_USE="$MODDED_FILE"
			else
				echo "Modulation of image failed." >&2
			fi
		fi

		jxsetbg "$FILE_TO_USE"

		# if fadebg "$JPATH/background1.jpg" "$FILE"
		# else
			# jshwarn "fadebg failed on $FILE"
		# fi

		[ "$?" = 0 ] && break
	else
		jshwarn "Wallpaper $FILE does not exist or is not an image or is too small!"
	fi

done
