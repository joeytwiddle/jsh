# OPTS="-vo x11"
OPTS="-vo xv"
if test "$1" = "-turbo"
then
	shift
	OPTS="-vo sdl"
fi
OPTS="$OPTS -ao sdl -zoom -idx"
unj mplayer $OPTS "$@"
