#!/bin/sh
# import -window root /tmp/screenshot-$$.bmp
# ## I think it would be good if:
# echo /tmp/screenshot-$$.bmp

DESTDIR=/tmp
DESTDIR="$HOME/screenshots" ; mkdir -p "$DESTDIR" || exit 1

windowid="root"
if [ "$1" = "-window" ]
then
	shift
	windowid=`xdotool getwindowfocus`
fi

if [ "$1" = --help ]
then
	echo "xsnapshot [-window]"
	echo "  will take a screenshot of the current desktop (or with -window the currently focused window) and save it in $DESTDIR"
	exit 0
fi

if [ "$1" ]
then DESTINATION="$1"
#else DESTINATION="$DESTDIR"/screenshot-$$.png
else DESTINATION="$DESTDIR"/"$USER"@"$(hostname) at $(date +"%-I:%M %p on %A %-d %B %Y").png"
fi

## ATM we force output as .bmp because other programs may be expecting .bmps.
## But we could just scrap compatibility with them, and save pngs instead (much smaller but require processing).

TMPFILE=/tmp/screenshot-$$-tmp.bmp
import -window "$windowid" "$TMPFILE"

# if endswith "$DESTINATION" .bmp
# then mv "$TMPFILE" "$DESTINATION"
# else convert "$TMPFILE" "$DESTINATION"
# fi
nice -n 5 convert "$TMPFILE" "$DESTINATION" && rm -f "$TMPFILE"

echo "$DESTINATION"
