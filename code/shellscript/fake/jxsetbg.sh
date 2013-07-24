#!/bin/sh

require_exes xsetbg || require_exes fbsetbg || exit

IMAGE="$1"

# xv is centralised and smoothscales =) but non-free :-/
( which xv > /dev/null 2>&1 && xv -root -rmode 5 -maxpect -quit "$IMAGE" 1>&2 ) ||

## xsetbg is faster, but sometimes poor aspect for tall pictures, and doesn't support bmp
## TODO: convert to jpeg if bmp offered!
# `jwhich xsetbg` -dither -fullscreen -border black "$IMAGE" ||
# `jwhich xsetbg` -fullscreen -onroot -fit -border black "$IMAGE" ||
(
	echo "Converting..." >&2
	## CONVERTOPTS="-interlace Plane"

	## Why do we convert?  Because xsetbg barfs on some file-formats that convert does not.  :)

	## If the aspect is within a certain band, resize the image to fix the screen exactly.
	if which convert >/dev/null 2>&1
	then

		SIZE=`imagesize "$IMAGE"` # | pipeboth
		XRES=`echo "$SIZE" | beforefirst x`
		YRES=`echo "$SIZE" | afterfirst x`
		ASPECT_PERCENT=$((XRES*100/YRES))
		if [ "$ASPECT_PERCENT" -gt 123 ] && [ "$ASPECT_PERCENT" -lt 141 ]
		then FIX='!'
		fi
		# jshinfo "aspect=$ASPECT_PERCENT FIX=$FIX"

		# DITHER=just_testing ## todo: autodetect via xdpyinfo
		if [ "$DITHER" ]
		then convert "$IMAGE" -geometry 1280x1024"$FIX" -depth 8 -dither $CONVERTOPTS /tmp/tmp-dithered.png && IMAGE=/tmp/tmp-dithered.png
		else convert "$IMAGE" -geometry 1280x1024"$FIX" $CONVERTOPTS /tmp/tmp.png && IMAGE=/tmp/tmp.png
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

