killall xscreensaver
# OPTS="-vo x11" # -stop_xscreensaver"
OPTS="-vo xv" ## allows me to adjust contrast!
# OPTS="-vo xv"
if test "$1" = "-turbo"
then
	shift
	OPTS="-vo sdl"
fi
OPTS="$OPTS -ao sdl -zoom -idx"
unj mplayer $OPTS "$@"
[ "$DISPLAY" = ":0" ] && xscreensaver &
