## TODO: jmusic shaould have lock/active/run-file?

## Doa quick fadevolume before ending song, then restore volume for next song.

quickfadevolume () {
  ORIGINAL_VOLUME=`aumix -q | grep "vol" | sed 's+vol ++;s+,.*++'`
	fadevolume 0
}

restorevolume () {
  aumix -v "$ORIGINAL_VOLUME"
}

## Should be whichmediaplayer
# xmmsisplaying () {
	# top c n 1 b | head -50 | grep xmms > /dev/null
# }

whichmediaplayer () {
	# fuser -v /dev/dsp | drop 2 | head -n 1 | takecols 5
	## New fuser appears to output on stderr?
	fuser -v /dev/dsp 2>&1 | grep "^/dev/dsp" | head -n 1 | takecols 5
}

PLAYER=`whichmediaplayer`

quickfadevolume

case $PLAYER in
	xmms)
		xmms -f
	;;
	mpg123|ogg123|mpg321)
		killall -sINT $PLAYER ## send it something softer
	;;
	mplayer)
		## No good, doesn't progress to next song.  Want to send it a signal!
		killall mplayer ## send it something softer
	;;
	*)
		error "$0: Don't know how to operate your media player: $PLAYER"
	;;
esac

## On my system this prevents a tiny bit of the old audio continuing after the kill,
## but on your system it might take longer, or it might clip a second of the new song!  But who cares, it's only a second right?
sleep 1
restorevolume

sleep 3
whatsplaying

