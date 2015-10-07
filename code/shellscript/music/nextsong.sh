#!/bin/sh
## Fades down the volume, then switches your media player to the next song (hopefully), and restores the original volume.
## 2010-04-28: Changed all "vol " to "pcm " and all aumix -v to aumix -w, here and in 'fadevolume'.

## TODO: jmusic should have lock/active/run-file?

fade_all_mixers () {
	export AUMIX_OPTS
	for MIXER in /dev/mixer*
	do AUMIX_OPTS="-d $MIXER" ; quickfadevolume & ## fade all mixers simultaneously
	done
	wait
}
## Do a quick fadevolume before ending song, then restore volume for next song.
quickfadevolume () {
	DOWNSTEP=5 nice -n 5 fadevolume 0
}

## TODO: This needs to remember values for each mixer
remember_volume () {
	## We record "current" volume from the first mixer/soundcard.
	## But we will actually fade the first two mixers on the machine, and restore both to the recorded volume.
	# ORIGINAL_VOLUME=`aumix -d /dev/mixer -q | grep "pcm " | sed 's+pcm ++;s+,.*++'`
	ORIGINAL_VOLUME=`get_volume`
}
## This is called once for each mixer
restorevolume () {
	# aumix $AUMIX_OPTS -w "$ORIGINAL_VOLUME"
	set_volume "$ORIGINAL_VOLUME"
	# /usr/sbin/alsactl restore
}

## Should be whichmediaplayer
# xmmsisplaying () {
	# top c n 1 b | head -50 | grep xmms > /dev/null
# }

whichmediaplayer () {

	# Quick cheat - look for xmms where I expect it
	verbosely listopenfiles -allthreads xmms | grep "\(/dev/dsp\|/dev/snd/.\)" |
		grep -v "/dev/snd/control" | takecols 1 | head -n 1 |
	grep . ||

	## This method stopped working when mplayer was binding to /dev/snd/pcmC0D0p (later /dev/snd/pcmC2D0p) (redirecting to 3rd sndcard via config) instead of /dev/dsp:
	## However /dev/snd/controlC0 (,1,2) might work ok
	# fuser -v /dev/dsp | drop 2 | head -n 1 | takecols 5
	## New fuser appears to output on stderr?
	verbosely fuser -v /dev/dsp /dev/snd/controlC* 2>&1 | ## i want stderr because *some* systems put the info there!
	# grep -A999 "^/dev/dsp" | ## skip any errors at the start
		grep -A999 "^/" | ## skip any errors at the start
		grep -v "\<ut-bin\>" | ## don't mistake the game for a media player!  (Alternatively, grep *for* the media players we recognise below)
		grep -v "\<TeamSpeak.bin\>" | ## don't mistake this for a media player!  (Alternatively, grep *for* the media players we recognise below)
		sed 's+.* ++' | grep -v "^COMMAND$" | grep -v "^$" | ## take the last col from each line, that isn't the leading blank or the header
		head -n 1 |
		# | takecols 5
	grep . ||

	## This is pretty solid (probably the first media player I opened), but it's too damn slow!
	verbosely listopenfiles -allthreads . | grep "\(/dev/dsp\|/dev/snd/.\)" | grep -v "/dev/snd/control" | takecols 1 | head -n 1

}

remember_volume

( fade_all_mixers ) &

PLAYER=`whichmediaplayer`
jshinfo "Detected media player: $PLAYER"

is_running() {
	if findjob "$1" >/dev/null
	then echo "$1"
	else return 1
	fi
}

if [ "$PLAYER" = "pulseaudio" ]
then PLAYER=`is_running xmms || is_running mplayer || is_running mpg123 || is_running ogg123`
fi

wait

case $PLAYER in
	xmms)
		## Added stop and start (-s and -p) in an attempt to avoid the audio clipping problem below.
		## xmms was returning before the playing song had actually stopped or advanced.
		xmms -s
		xmms -f
		xmms -p
	;;
	amarok|yauap)
		## Does not work!
		# amarok -f
		:
	;;
	audacious)
		# # audtool -s
		# audtool -f
		# # audtool -p
		## Gentoo:
		audtool playlist-advance
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
for MIXER in /dev/mixer*
do AUMIX_OPTS="-d $MIXER" ; restorevolume &
done

## Since the above doesn't work
#gksudo alsactl restore

## Display the new song, for convenience (wait a bit to be sure it's started):
(
	sleep 3
	whatsplaying
) &

