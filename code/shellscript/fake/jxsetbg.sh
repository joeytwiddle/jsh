IMAGE="$1"

# xv is centralised and smoothscales =) but non-free :-/
( which xv > /dev/null 2>&1 && xv -root -rmode 5 -maxpect -quit "$IMAGE" 1>&2 ) ||

## xsetbg is faster, but sometimes poor aspect for tall pictures, and doesn't support bmp
## TODO: convert to jpeg if bmp offered!
# `jwhich xsetbg` -dither -fullscreen -border black "$IMAGE" ||
# `jwhich xsetbg` -fullscreen -onroot -fit -border black "$IMAGE" ||
(
	echo "Converting..." >&2
	which convert > /dev/null && convert "$1" -geometry 1280x1024 /tmp/tmp.jpg && IMAGE=/tmp/tmp.jpg
	unj xsetbg -fullscreen -onroot -fit -border black "$IMAGE"
) ||

## xsetroot is just pants
xsetroot -bitmap "$@" 1>&2
