#!/bin/sh

# See also: maim https://github.com/naelstrof/maim
#           E.g. https://github.com/iynaix/dotfiles-yadm/blob/master/bin/rofi-screenshot

# Redux:
#import -window root /tmp/screenshot-$$.bmp && echo /tmp/screenshot-$$.bmp

killall osd_cat 2>/dev/null

DESTDIR=/tmp
DESTDIR="$HOME/screenshots" ; mkdir -p "$DESTDIR" || exit 1

nicedate="$(date +"%-I:%M:%S %p on %A %-d %B %Y")"

if command -v screencapture >/dev/null
then
	# MacOS

	if [ "$1" = -window ]
	then
		shift
		DESTINATION="$DESTDIR"/"$USER's app at $nicedate.png"
		[ -n "$1" ] && DESTINATION="$1"

		# Not easy
		# https://apple.stackexchange.com/questions/56561/how-do-i-find-the-windowid-to-pass-to-screencapture-l
		#screencapture -l"$window_id" "$DESTINATION"

		# For now, just capture the entire desktop
		screencapture "$DESTINATION"
	else
		DESTINATION="$DESTDIR"/"$USER's desktop on `hostname` at $nicedate.png"
		[ -n "$1" ] && DESTINATION="$1"

		screencapture "$DESTINATION"
	fi

	exit
fi

windowid="root"
if [ "$1" = "-window" ]
then
	shift
	windowid=`xdotool getwindowfocus`
	#app_name="`xdotool getwindowname "$windowid"`"
	app_name="`xprop -id "$windowid" | grep "^WM_CLASS(STRING)" | sed 's+.*"\(.*\)"$+\1+'`"
	sanitized_app_name="`printf "%s" "$app_name" | tr '#/' '__'`"
	window_description="$USER's $sanitized_app_name"
else
	window_description="$USER's desktop on `hostname`"
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
else DESTINATION="$DESTDIR"/"$window_description at $nicedate.png"
fi

## ATM we force output as .bmp because other programs may be expecting .bmps.
## But we could just scrap compatibility with them, and save pngs instead (much smaller but require processing).

TMPFILE=/tmp/screenshot-$$-tmp.bmp
import -window "$windowid" "$TMPFILE"

# For Mac OS X:
#screencapture screen1.png screen2.png ...

if which osd_cat >/dev/null 2>&1
then
	killall osd_cat 2>/dev/null
	#font='-*-helvetica-*-r-*-*-*-400-*-*-*-*-*-*'
	#font='-*-nimbus roman no9 l-*-r-*-*-60-*-*-*-*-*-*-*'
	font='-*-helvetica-*-r-*-*-24-*-*-*-*-*-*-*'
	echo "Saved screenshot at\n\n$DESTINATION" |
	#echo "Moved desktop $fromDesktop $direction" |
	osd_cat -o 200 -d 2 -A center -c yellow -O 2 -f "$font"
fi

# if endswith "$DESTINATION" .bmp
# then mv "$TMPFILE" "$DESTINATION"
# else convert "$TMPFILE" "$DESTINATION"
# fi
nice -n 5 convert "$TMPFILE" "$DESTINATION" && rm -f "$TMPFILE"

echo "$DESTINATION"
