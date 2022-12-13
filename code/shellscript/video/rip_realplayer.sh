#!/bin/bash

## BBC news:      http://www.bbc.co.uk/newsa/n5ctrl/tvseq/bb_news_ost.ram
## Newsnight:     http://www.bbc.co.uk/newsa/n5ctrl/tvseq/newsnight/newsnight.ram
## Question time: http://www.bbc.co.uk/newsa/n5ctrl/progs/question_time/latest.ram
## Panorama:      http://www.bbc.co.uk/newsa/n5ctrl/progs/panorama/latest.ram

# export DISPLAY=:0
# br=8

## NOTE: as of now I am changing it to rip all types of stream, not only realmedia (currently starting to introduce mms: to this script)
## TODO: I want it to provide options to watch and / or capture.  I also would like it to be a "Web TV tuner", and even allow it to get another channel in a multitasking type way.
##       I doubt Xdialog can be used in a multitasking way nicely (killing it and respawning to present update will prolly kill users current gui state).  Is there a better alternative?

function nicefilename () {
	echo "$*" |
	tr '/:;"& ~<>'"'" '_'
}

if [ "$1" = -test ]
then shift; PREVIEW="-ss 0:00:00 -endpos 00:12"
fi

URL="$1"

if startswith "$URL" "http://"
then
	FILENAME=`nicefilename "$URL"`
	wget -nv "$URL" -O /tmp/rp.ram
	RPURL=`cat /tmp/rp.ram`
	if ! startswith "$RPURL" "rtsp://"
	then
		echo "Did not obtain an rtsp from /tmp/rp.ram obtained from $URL"
	fi
elif [ -f "$URL" ]
then
	FILENAME=`basename "$URL"`
	if [ `filesize "$FILENAME"` -lt 4096 ]
	then
		RPURL=`cat "$URL"`
	else
		RPURL="file://$URL"
	fi
else
	RPURL="$URL"
fi

# if ! startswith "$RPURL" "rtsp://" && ! startswith "$RPURL" "pnm://" && ! startswith "$RPURL" "file://"
if ! echo "$RPURL" | grep -E "^(rtsp|pnm|mms|file)://" >/dev/null
then
	error "Got $RPURL which is not (yet) one of the recognised protocols."
	exit 1
fi

[ "$FILENAME" ] || FILENAME=`nicefilename "$RPURL"`

# URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/question_time/latest.rm?start="00:00.0"'
# URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/tvseq/news_ost/bb_news10.rm?start="00:00.0"'
# URL='rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/panorama/latest.rm?start="00:00.0"'

# mencoder "./dune - original movie - directors cut.avi" -o "preview-1.avi" -oac copy -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=117105:vhq:vpass=1:vqmin=2:vqmax=10 -ss 0:19:00 -endpos 02:30 -vf scale=618:432,pp=de/hb/vb/dr/al/lb/tn:1:2:3 -ni -nobps -mc 1
# -vf pp=de/hb/vb/dr/al/lb/tn:1:2:3
# mencoder rtsp://rmv8.bbc.net.uk/news/olmedia/n5ctrl/progs/question_time/latest.rm?start="00:00.0" -o question_time.rm -oac mp3lame -lameopts br=8 -ovc lavc $PREVIEW # -lavcopts abitrate=8:acodec=mp2

# -lavcopts abitrate=8:acodec=mp2
# -lavcopts vqscale=6 ## <-- this approximately halves the size of the BBC news

## Sometimes mencoder cannot resample: "Couldn't open codec mp2, br=224".  So we make different attempts if it fails.
## TODO: Mplayer should attempt "audio-only" ripping before trplayer and realplayer are attempted (or does -ovc copy handle no video ok?) Well, it might, but I've used -ocv lavc below anyway!
for AUDIO_METHOD in "-oac lavc" "-oac pcm" NO_VIDEO_trplayer NO_VIDEO_realplay
do

	echo
	curseyellow
	echo "=============================================================================="
	echo "Making attempt with: $AUDIO_METHOD"
	echo "=============================================================================="
	cursenorm
	echo

	if [ "$AUDIO_METHOD" = NO_VIDEO_trplayer ]
	then
		OUTFILE="$FILENAME.wav"
		TRPLAYER=`which trplayer`
		if [ "$TRPLAYER" ]
		then
			verbosely vsound -v -f $OUTFILE -d -t $TRPLAYER "$RPURL"
		else false
		fi
	elif [ "$AUDIO_METHOD" = NO_VIDEO_realplay ]
	then
		OUTFILE="$FILENAME.wav"
		REALPLAY=`which realplay`
		if [ "$REALPLAY" ]
		then
			verbosely vsound -v -f $OUTFILE -d -t $TRPLAYER "$RPURL"
		else false
		fi
	else
		OUTFILE="$FILENAME".avi
		## TODO: For audio only streams, this fails with "Video stream is mandatory!"
		verbosely mencoder "$RPURL" -of avi -o "$OUTFILE" $AUDIO_METHOD -ovc lavc -lavcopts vqscale=6 $PREVIEW
	fi

	if [ "$?" = 0 ]
	then
		echo
		jshinfo "Stream happily saved to $OUTFILE"
		break
	else
		RES="$?"
		echo
		jshwarn "That attempt failed with code $RES (or was closed uncleanly); trying something different..."
		echo
		sleep 5
	fi

done

# if ! mencoder "$RPURL" -of avi -o out.avi -oac lavc -ovc lavc -lavcopts vqscale=6 $PREVIEW
# then
# 
	# ## This deals with the error: Couldn't open codec mp2, br=224
	# mencoder "$RPURL" -of avi -o out.avi -oac pcm -ovc lavc $PREVIEW
# 
# fi

# mencoder "$RPURL" -of avi -o out.avi -oac lavc -ovc lavc $PREVIEW
