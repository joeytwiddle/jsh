#!/bin/bash

# BUG: This reports xsetbg as required, even though this script in fact works fine without it.
#      But is there something a little better about xsetbg?
require_exes xsetbg || require_exes fbsetbg || exit

IMAGE="$1"

# xv is centralised and smoothscales =) but non-free :-/
( which xv > /dev/null 2>&1 && xv -root -rmode 5 -maxpect -quit "$IMAGE" 1>&2 ) ||

## xsetbg is faster, but sometimes poor aspect for tall pictures, and doesn't support bmp
## TODO: convert to jpeg if bmp offered!
# $(jwhich xsetbg) -dither -fullscreen -border black "$IMAGE" ||
# $(jwhich xsetbg) -fullscreen -onroot -fit -border black "$IMAGE" ||
(
	echo "Converting..." >&2
	## CONVERTOPTS="-interlace Plane"

	## Why do we convert?  Because xsetbg barfs on some file-formats that convert does not.  :)

	## If the aspect is within a certain band, resize the image to fix the screen exactly.
	if which convert >/dev/null 2>&1
	then

		## If image aspect ratio is similar to desktop aspect ratio, then stretch it instead of adding a border.
		DESKTOP_SIZE=$(getxwindimensions)
		DESKTOP_XRES=$(echo "$DESKTOP_SIZE" | beforefirst x)
		DESKTOP_YRES=$(echo "$DESKTOP_SIZE" | afterfirst x)
		DESKTOP_ASPECT_PERCENT=$((DESKTOP_XRES*100/DESKTOP_YRES))

		IMAGE_SIZE=$(imagesize "$IMAGE")
		IMAGE_XRES=$(echo "$IMAGE_SIZE" | beforefirst x)
		IMAGE_YRES=$(echo "$IMAGE_SIZE" | afterfirst x)
		IMAGE_ASPECT_PERCENT=$((IMAGE_XRES*100/IMAGE_YRES))

		RATIO_DIFFERENCE_PERCENT=$((DESKTOP_ASPECT_PERCENT - IMAGE_ASPECT_PERCENT))

		if [ "$RATIO_DIFFERENCE_PERCENT" -gt -8 ] && [ "$RATIO_DIFFERENCE_PERCENT" -lt 10 ]
		then FIX='!'
		fi


		## Stretch the image to fit the screen, giving it a border if necessary.
		# DITHER=just_for_fun ## todo: autodetect whether it is needed via xdpyinfo
		TARGET_DIMENSIONS=$(getxwindimensions)
		if [ "$DITHER" ]
		then convert "$IMAGE" -geometry "$TARGET_DIMENSIONS""$FIX" -depth 8 -dither $CONVERTOPTS /tmp/tmp-dithered.png && IMAGE=/tmp/tmp-dithered.png
		else convert "$IMAGE" -geometry "$TARGET_DIMENSIONS""$FIX" $CONVERTOPTS /tmp/tmp.png && IMAGE=/tmp/tmp.png
		fi

	fi

	if which xsetbg >/dev/null 2>&1
	then unj xsetbg -fullscreen -onroot -fit -border black "$IMAGE"
	elif which fbsetbg >/dev/null 2>&1
	then fbsetbg -A "$IMAGE"
	else
		echo "Can't find any command to set the background!" >&2
		# xsetroot -bitmap might do it but it requires some weird image format, and we'll probably need to do centering ourself (e.g. via imagemagick).
	fi
	# xview -fullscreen "$IMAGE" &
	# XVIEWPID="$!"
	# sleep 5
	# kill "$XVIEWPID"
	# true
) ||

## xsetroot is just pants
xsetroot -bitmap "$@" 1>&2

