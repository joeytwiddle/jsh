# jsh-ext-depends-ignore: sync file from size strip
# this-script-does-not-depend-on-jsh: exists after before del off reencode_video_two_pass
## After the first audio pass, you can rerun with SKIP_FIRST_PASS=true.

## Note afterwards, leftover files are: sizes.log divx2pass.log frameno.avi (and of course the video file you started with!).

[ "$TARGETSIZE" ] && jshwarn "Variable TARGETSIZE has been renamed to TARGET_SIZE" && TARGET_SIZE="$TARGETSIZE"

if [ ! "$1" ] || [ "$1" = --help ]
then
more << !

reencode_video_three_pass <video_file>

  will reencode a video using mplayer's mencoder.

No options at the moment, but you can pass the following variables:

  TARGET_SIZE=<megabytes>    Set this to override the default filesize (700MB),
  BITRATE=<bps>              or this to specify the bitrate yourself.

And more...

  SKIP_FIRST_PASS=anything   Set this if you have already done the audio pass
                             (do not regenerate frameno.avi).
  PREVIEW="-ss 0:10:00 -endpos 0:10"  (requires a separate first pass)
  NEWSIZE="720:400"
  ALL_FILTERS=true   or   POSTPROC="de/hb/vb/dr/al/lb/tn:1:2:3"
  AUDIO_BITRATE=<kbps>       (default 128)
  OAC="mp3lame -lameopts abr:br=$AUDIO_BITRATE"
                             Use this if OAC=copy fails.

  PERFORM_AUTOMATIC_CROPPING=true   To strip black areas off the edges =)
    ( Warning: ATM kills others running copies of mplayer! )

  If you want to do cropping and scaling, use something like:
    EXTRAOPTS="-vf crop=336:144:8:46,scale=336:150"

(If you lose a/v sync after re-encoding, try reencode_video_two_pass instead.)

!
#  OAC=pcm                    Use this if OAC=copy fails.
#  OAC="lavc=1"               Use this if OAC=copy fails.
exit 1
fi

## I wanted to make a script which would make it easy to reencode videos.
## I didn't really care to learn about mencoder's options and so on.
## Well, this script has made it a little easier, but I still find myself typing: env PREVIEW="-ss 3:20 -endpos 0:10" SKIP_FIRST_PASS= BITRATE=4000 reencode_video_three_pass ./The\ Fog\ of\ War\ CD1.mpg

# SKIP_FIRST_PASS=true
# PREVIEW="-ss 0:00:00 -endpos 0:15"
# PREVIEW="-ss 0:50:00 -endpos 0:20"
# POSTPROC="-de"
# POSTPROC="de" ## Default filters
# POSTPROC="al" ## Just automatic brightness/contrast
# POSTPROC="de/dr/al/lb" ## Defaults + deringing, automatic brightness/contrast and linear blend deinterlacer
# POSTPROC="de/hb/vb/dr/al/lb" ## Defaults + horizontal and vertical deblocking, deringing, automatic brightness/contrast and linear blend deinterlacer
# POSTPROC="de/tn:1:2:3" ## Defaults + temporal denoiser
[ "$ALL_FILTERS" ] && POSTPROC="de/hb/vb/dr/al/lb/tn:1:2:3" ## Everything!

## See options only needed for later passes below...

## TODO: audio/video sync always seems out by about 0.8s.  Fudge/fix it somewhere!
##       Make the fix optional.  Consider which of the input or output format cause this problem
##       Check whether this problem is not just a result of playback!
## Oh dear, the only method which accepts -ve audio delay (I found no +/-ve video delay) is for mplayer, not mencoder, so we would have to do an mplayer pass to use it.  Yuk!
# AUDIODELAYFIX="-af delay=1000:1000"
## Mmm wait, there seem to be -audio-delay (for avi) and -delay options we could try.

INPUT="$1"
LANG=en

# SIZELOG="/tmp/sizes.log"
SIZELOG="sizes.log" # since frameno.avi and divx2pass.log appear in cwd anyway

## TODO: cleanup /if/ doing first pass

## First pass to generate audio/frameno file:
if [ ! "$SKIP_FIRST_PASS" ]
then
	[ "$AUDIO_BITRATE" ] || AUDIO_BITRATE=128
	del frameno.avi divx2pass.log
	jshinfo "############################ Audio pass"
	jshinfo "## mencoder \"$INPUT\" $EXTRAOPTS $PREVIEW $AUDIODELAYFIX -ovc frameno -o frameno.avi -oac mp3lame -lameopts abr:br=$AUDIO_BITRATE -alang \"$LANG\""
	nice -n 12  mencoder  "$INPUT"  $EXTRAOPTS $PREVIEW $AUDIODELAYFIX -ovc frameno -o frameno.avi -oac mp3lame -lameopts abr:br=$AUDIO_BITRATE -alang "$LANG" 2>&1 | tee "$SIZELOG" || exit
	## Added 2>&1 because recommended bitrate info was getting lost.  But that could have just be tee breaking out when mencoder finished, yuk!  (If this behaviour was consistent with earlier versions, which it isn't, we could ignore stdout which is big!)
	jshinfo
fi

## Obtain recommended bitrate:
if [ "$BITRATE" ]
then jshinfo "Using user supplied bitrate $BITRATE"
else
	BITRATE=`tail -50 "$SIZELOG" | grep "Recommended video bitrate for 700MB CD: " | afterlast ": "`
	if [ "$TARGET_SIZE" ] && [ "$TARGET_SIZE" -gt 0 ]
	then
		AUDIOSIZE=`filesize "frameno.avi"`
		AUDIOSIZE=`expr "$AUDIOSIZE" / 1024 / 1024`
		jshinfo "Audio stream is currently $AUDIOSIZE""M."
		if [ "$AUDIOSIZE" -gt "$TARGET_SIZE" ]
		then jshwarn "Cannot generate file size $TARGET_SIZE""M when audio stream is larger ($AUDIOSIZE""M)!  You might try reducing the audio bitrate."
	  else
			TARGETBITRATE=`expr '(' "$TARGET_SIZE" - "$AUDIOSIZE" ')' '*' "$BITRATE" / '(' 700 - "$AUDIOSIZE" ')'`
			if [ "$TARGETBITRATE" -gt 0 ]
			then
				jshinfo "Calculated from 700M bitrate $BITRATE that $TARGET_SIZE""M requires bitrate $TARGETBITRATE"
				BITRATE="$TARGETBITRATE"
			else jshwarn "Calculation of required bitrate for target size $TARGET_SIZE failed."
			fi
		fi
	fi
	if [ "$BITRATE" ] && [ "$BITRATE" -gt 2 ] && [ "$BITRATE" -lt 9999999 ]
	then jshinfo "Using recommended bitrate $BITRATE"
	else
		jshwarn "Using fallback bitrate 1000 (because the recommended bitrate \"$BITRATE\" was dodgy)"
		BITRATE=1000
	fi
fi

# BITRATE=`expr "$BITRATE" '*' 25 / 100`
# BITRATE=`expr "$BITRATE" '*' 28 / 100`

# PREVIEW="-ss 0:13:30 -endpos 0:15"

# NEWSIZE="720:400"
# BITRATE=`expr "$BITRATE" / 2` ## For BotB
# EXTRAOPTS="-ni -nobps"                      ## For Dune sync I hope!
# EXTRAOPTS="$EXTRAOPTS -fps 29.9 -ofps 29.9" ## For Dune sync I hope!
# EXTRAOPTS="-aspect 352:264"
# BITRATE=4000 ## For Step into Liquid

jshinfo "Using bitrate $BITRATE"

find_cropping_params() {
	jshinfo "Guessing cropping params..."
	## This function stolen from: http://thern.org/projects/mencoder-script
	mplayer -ao null -vo null -vop cropdetect -ss 100 "$INPUT" > cropdetect.data &
	MPLAYERPID="$!"
	sleep 5
	killall -9 mplayer
	# kill -9 "$MPLAYERPID" ## <-- Doesn't work :/
	# mykill -x cropdetect works though
	sleep 5
	CROP=`tail -2 cropdetect.data | head -1 | awk -F"(" '{print $2}' | awk -F")" '{print $1}'`
	jshinfo "Adding cropping parameters: $CROP"
	EXTRAOPTS="$EXTRAOPTS $CROP"
}

[ "$PERFORM_AUTOMATIC_CROPPING" ] && find_cropping_params

## Second and third passes (preview or final):
# Postprocessing: -vf pp=hb/vb/dr/al/lb   
addfilter () {
	if [ "$FILTERS" ]
	then FILTERS="$FILTERS,"
	else FILTERS="-vf "
	fi
	FILTERS="$FILTERS$1=$2"
}
[ "$NEWSIZE" ] && addfilter scale "$NEWSIZE"
[ "$NEWSIZE" ] && addfilter dsize "$NEWSIZE" ## This overwrites old aspect ratio with one implied by new size. =)
[ "$POSTPROC" ] && addfilter pp "$POSTPROC"
## Does it really matter if the output of the first pass goes into the final file?  Probably not, if/since with this method, it's size is no larger than final file will be.  But /dev/null is slightly faster!
# FIRST_VIDEO_PASS_GOES_TO=/dev/null
# FIRST_VIDEO_PASS_GOES_TO=preview.avi
FIRST_VIDEO_PASS_GOES_TO="$INPUT".reencoded.avi
for PASS in 1 2
do
	[ $PASS = 1 ] && OUTPUT="$FIRST_VIDEO_PASS_GOES_TO" || OUTPUT="$INPUT".reencoded.avi
	# vqmin=2:vqmax=31:
	# ENCODING="-oac copy -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=$BITRATE:vhq:vpass=$PASS"
	[ "$CODEC" ] ||
	CODEC="mpeg4"
	# CODEC="msmpeg4"
	# CODEC="msmpeg4v2"
	[ "$OAC" ] || OAC="copy"
	ENCODING="-oac $OAC -ovc lavc -lavcopts vcodec=$CODEC:vbitrate=$BITRATE:vhq:vpass=$PASS"
	jshinfo "############################ Pass $PASS / 2"
	jshinfo "## mencoder \"$INPUT\" -o \"$OUTPUT\" $EXTRAOPTS $ENCODING $PREVIEW $AUDIODELAYFIX $FILTERS"
	nice -n 12  mencoder  "$INPUT"  -o  "$OUTPUT"  $EXTRAOPTS $ENCODING $PREVIEW $AUDIODELAYFIX $FILTERS \
		|| exit
	[ "$PASS" = 1 ] && [ -f "$OUTPUT" ] && del "$OUTPUT" ## Cleanup if preview was created.
	jshinfo
done

# jsh-ext-depends: tee mencoder killall mplayer
# jsh-depends: afterlast filesize mplayer jshwarn jshinfo
