# xtermsh "cd \"$1\"; jsh"

TODIR="$1"
shift
TODO="$@"
if [ ! "$TODO" ]
then TODO="bash"
fi
xtermsh "cd \"$TODIR\"; $TODO"
