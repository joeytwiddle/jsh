COM="$@"

TMPSH=`jgettmp "xtermsh.sh"`
(
	if test "$COM" = ""
	then cat
	else echo "$COM"
	fi
) > "$TMPSH"
chmod a+x "$TMPSH"

## We bg garbage collection, in case the user Ctrl+C's the inline call
(sleep 1m; jdeltmp "$TMPSH") &

if xisrunning
then
	# konsole -vt_sz 120x60 -nowelcome -caption "$1" -e sh "$TMPSH" &
	xterm -e "$TMPSH" &
else
	"$TMPSH"
fi
