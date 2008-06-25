## Fades down the volume, then switches your media player to the next song (hopefully), and restores the original volume.

## TODO: jmusic should have lock/active/run-file?

## Do a quick fadevolume before ending song, then restore volume for next song.
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
	fuser -v /dev/dsp 2>&1 |
	grep "^/dev/dsp" | ### ignore any errors at the start
	grep -v "\<ut-bin\>" | ## don't mistake the game for a media player!  (Alternatively, grep *for* the media players we recognise below)
	grep -v "\<TeamSpeak.bin\>" | ## don't mistake this for a media player!  (Alternatively, grep *for* the media players we recognise below)
	sed 's+.* ++' | grep -v "^COMMAND$" | grep -v "^$" | ## take the last col from each line, that isn't the leading blank or the header
	head -n 1 # | takecols 5
}

PLAYER=`whichmediaplayer`

quickfadevolume

case $PLAYER in
	xmms)
		## Added stop and start (-s and -p) in an attempt to avoid the audio clipping problem below.
		xmms -s
		xmms -f
		xmms -p
	;;
	mpg123|ogg123|mpg321)
		killall -sINT $PLAYER ## send it something softer?  we assume they are being called in a loop ;)
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
## but on your system it might take longer, or it might clip a second off the start of the new song!  But who cares, it's only a second right?
## CONSIDER: could wait until we're sure the next song has started (by checking whatsplaying)
sleep 1
restorevolume

## Display the new song, for convenience (wait a bit to be sure it's started):
sleep 3
whatsplaying

