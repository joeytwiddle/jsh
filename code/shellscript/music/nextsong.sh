## TODO: jmusic should have lock/active/run-file?

## Should be whichmediaplayer
# xmmsisplaying () {
	# top c n 1 b | head -50 | grep xmms > /dev/null
# }

whichmediaplayer () {
	# fuser -v /dev/dsp | drop 2 | head -1 | takecols 5
	fuser -v /dev/dsp | grep "^/dev/dsp" | head -1 | takecols 5
}

PLAYER=`whichmediaplayer`

case $PLAYER in
	xmms)
		xmms -f
	;;
	mpg123)
		killall mpg123 ## send it something softer
	;;
	*)
		error "Don't know how to operate your media player: $PLAYER"
	;;
esac
