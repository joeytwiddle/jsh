#!/bin/sh
## Fades down the volume, then switches your media player to the next song (hopefully), and restores the original volume.
## 2010-04-28: Changed all "vol " to "pcm " and all aumix -v to aumix -w, here and in 'fadevolume'.

## TODO: jmusic should have lock/active/run-file?

# On my current system, set_volume uses amixer, and targets only one channel.
fade_all_mixers () {
	quickfadevolume
}
# But on a system with ALSA present, we can use aumix to fade all mixers.
fade_all_mixers_REAL () {
	#export AUMIX_OPTS
	# On my naff machine I don't have /dev/mixer[N] devices, but I think we iterate once with '/dev/mixer*'
	# If amixer is present, it doesn't matter, because @see set_volume uses that but always points to the first mixer.
	for MIXER in /dev/mixer*
	do
		export AUMIX_OPTS="-d $MIXER"
		## We background this, in order to fade all mixers simultaneously
		quickfadevolume &
	done
	wait
}

## Do a quick fadevolume before ending song, then restore volume for next song.
quickfadevolume () {
	DOWNSTEP=2 fadevolume 0.2
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
	#verbosely 
	listopenfiles -allthreads xmms | grep "\(/dev/dsp\|/dev/snd/.\)" |
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

make_media_player_skip() {

	PLAYER=`whichmediaplayer`
	jshinfo "[nextsong] Detected media player: $PLAYER"

	is_running() {
		if findjob "$1" >/dev/null
		then echo "$1"
		else return 1
		fi
	}

	if [ "$PLAYER" = "pulseaudio" ]
	then
		#echo "Killing pulseaudio is not enough to search the song."
		PLAYER=`is_running xmms || is_running mplayer || is_running mpg123 || is_running ogg123`
		jshinfo "[nextsong] I don't want to kill pulseaudio. But I found running process: $PLAYER"
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
			if [ -e /tmp/mplayercontrol."$USER" ]
			then echo "pt_step +1" > /tmp/mplayercontrol."$USER"
			else killall mplayer # (assume we are using playmp3.sh)
			fi
		;;
		*)
			error "$0: Don't know how to operate your media player: $PLAYER"
		;;
	esac
}



whatsplaying &

remember_volume

fade_all_mixers

make_media_player_skip

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
	# Wow it is taking a really long time on my current system
	# The randommp3 has some sleeps in it at the moment, which may be the cause.
	#sleep 12
	# Yes it was.
	whatsplaying
) &

wait
