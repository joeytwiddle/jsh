if test "$1" = ""; then
	echo "changewm <name_of_next_window_manager>"
	echo "  only works if you are using Joey's .xinitrc"
	exit 1
fi

# Hopefully passed down from .xinitrc
# Nah didn't!
CURRENTWMFILE="$JPATH/data/currentwinman.$DISPLAY.dat"
if [ ! -f "$CURRENTWMFILE" ]
then
	DISPLAY=`echo "$DISPLAY" | beforelast "\."`
	CURRENTWMFILE="$JPATH/data/currentwinman.$DISPLAY.dat"
fi
NEXTWMFILE="$JPATH/data/nextwinman.$DISPLAY.dat"

echo "$1" > "$NEXTWMFILE"

CWM=`cat "$CURRENTWMFILE"`
killall "$CWM"

## For convenience (otherwise done by .xinitrc):
echo "$1" > "$CURRENTWMFILE"
