OPTS="-vo x11"
if test "$1" = "-turbo"
then
	shift
	OPTS="-vo sdl"
fi
OPTS="$OPTS -ao sdl -zoom -idx"
`jwhich mplayer` $OPTS "$@"
