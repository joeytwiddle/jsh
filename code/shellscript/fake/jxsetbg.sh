#!/bin/bash

# xsetbg is preferred because it will leave a border around an image; fbsetbg will stretch to git, regardless of aspect ratio.
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

	if which convert >/dev/null 2>&1
	then

		## If image aspect ratio is similar to desktop aspect ratio, then stretch it to fit screen exactly, otherwise add a border.
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


		## Stretch the image to fit the screen.  Does not give it a border; xsetbg will do that later.
		# DITHER=just_for_fun ## todo: autodetect whether it is needed via xdpyinfo
		TARGET_DIMENSIONS=$(getxwindimensions)
		## +dither
		## -dither FloydSteinberg
		## -dither Riemersma
		if [ -n "$DITHER" ]
		then convert "$IMAGE" -geometry "$TARGET_DIMENSIONS""$FIX" -depth 8 +dither $CONVERTOPTS /tmp/tmp-dithered.jpg && IMAGE=/tmp/tmp-dithered.jpg
		else convert "$IMAGE" -geometry "$TARGET_DIMENSIONS""$FIX" $CONVERTOPTS -quality 100% /tmp/tmp.jpg && IMAGE=/tmp/tmp.jpg
		fi
		## I was convering to png above, but something weird was happening with ImageMagick 6.7.7-10:
		## - The image was appearing darker than expected
		## - xsetbg was later reporting: "PNG file: /tmp/tmp.png - Application must supply a known background gamma"
		## This was happening for images with no transparency.
		## Converting to 100% quality jpg solved these issues.  (And is probably also faster - see discussion in randomwallpaper.)

	fi

	# fbsetbg -A maximized and crops.  Only use it instead of -c if you have not scaled the image to the appropriate size.  (We do this above.)

	if which fbsetbg >/dev/null 2>&1
	then
		#fbsetbg -c "$IMAGE"
		# Sometimes when running this I get an error (through xmessage) telling me to run this to see what went wrong:
		#     display -backdrop -window root /tmp/tmp.jpg
		# If I run that, it actually works fine, but there is a non-zero exit code.  We could probably just ignore it.

		# To avoid the xmessage error, let's use display instead of fbsetbg
		# Note that this works for jpg files but not for png files!
		if ! endswith "$IMAGE" ".jpg" && ! endswith "$IMAGE" ".jpeg"
		then convert "$IMAGE" "$IMAGE.jpg" && IMAGE="$IMAGE.jpg"
		fi
		display -backdrop -window root "$IMAGE" || true
	elif which xsetbg >/dev/null 2>&1
	then
		unj xsetbg -fullscreen -onroot -fit -border black "$IMAGE"
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

## On some systems, xsetroot can only handle xbm files (not even png)
## BUG TODO : Unfortunately when we convert xbm this way, it produces a 2-color image!
#convert "$IMAGE" "$IMAGE.xbm" && IMAGE="$IMAGE.xbm" &&
xsetroot -bitmap "$IMAGE" 1>&2
