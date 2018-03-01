if [ "$1" = "" ] || [ "$1" = --help ]
then
cat << !

  reencode_video_two_pass <input_video_filename>

    will reencode the video using transcode (which is sometimes able to retain
    A/V sync when mencoder cannot).

    For the moment, you must set either the environment variable:
      export LENGTH_IN_SECONDS=<duration_of_video>
    or:
      export VIDEO_BITRATE=<kbits/s>

    You may optionally set:
      export AUDIO_BITRATE=<kbit/s>      (default 48kbps)
      export TARGET_SIZE=<desired_meg>   (default 700Mb)
      export PREVIEW="-c 5:00-6:00"
      export EXTRA_TRANSCODE_OPTS="-Z 720x576,fast"

    The automatic calculation of VIDEO_BITRATE from LENGTH_IN_SECONDS tends to
    produce videos in the range 670-700 Mb.  Maybe the algorithm can be
    improved to move closer to the latter...

    TODO BUG: If you run this on a non-writeable or non-Unix fs, then it fails
              because it can't make a fifo.  Fix: run from /tmp with symlinks.

!
exit 1
fi

INPUT="$1"
OUTPUT="$INPUT.reencoded.avi"

## Delays (pads at start) audio by 6 frames:
# EXTRA_TRANSCODE_OPTS="-D -6 $EXTRA_TRANSCODE_OPTS"

## Be gentle:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

# del transcode_out.avi
rm -f ./stream.yuv

[ "$TARGET_SIZE" ] || TARGET_SIZE=700
if [ ! "$AUDIO_BITRATE" ]
then
	## TODO: should make this 48 if it needs to be low.
	## DONE: nah should default to 128 cos anything lower sucks!
	# AUDIO_BITRATE=64
	AUDIO_BITRATE=128
	jshinfo "Defaulting AUDIO_BITRATE of output to $AUDIO_BITRATE kilobits per second."
fi
# FUDGE_FACTOR=128
# VIDEO_BITRATE=`expr "$TARGET_SIZE" '*' 1024 '*' 1024 / "$LENGTH_IN_SECONDS" / "$FUDGE_FACTOR" - "$AUDIO_BITRATE"`
## Right it's in kilobits per second not bytes per second
if [ ! "$VIDEO_BITRATE" ]
then
	if [ ! "$LENGTH_IN_SECONDS" ]
	then
		error "To automatically calculate VIDEO_BITRATE, you must: export LENGTH_IN_SECONDS=<length_of_video_in_seconds>"
		exit 1
	fi
	VIDEO_BITRATE=`expr "$TARGET_SIZE" '*' 1024 '*' 1024 '*' 8 / "$LENGTH_IN_SECONDS" / 1024 - "$AUDIO_BITRATE"`
	jshinfo "For target size $TARGET_SIZE""Mb, required video bitrate is ~ $VIDEO_BITRATE"
fi
if [ "$VIDEO_BITRATE" -lt 7000 ]
then
	VIDEO_BITRATE=7000
	jshinfo "Adjusted VIDEO_BITRATE to $VIDEO_BITRATE to avoid \"requested bitrate is too low\" error on second pass"
fi

# OUTPUT_CODEC="-y ffmpeg,mjpeg -F mpeg4" ## I tried some others because this one was slow to playback at 1024x576 but this one beat them all for size (very slightly).
# OUTPUT_CODEC="-y mjpeg,mjpeg" ## Very slow to playback
# OUTPUT_CODEC="-y divx5,divx5" ## No better (and unsupported, soon to be removed)
# OUTPUT_CODEC="-y divx4,divx4" ## I don't have dependencies (probably also unsupported)
# OUTPUT_CODEC="-y xvid4,mjpeg" ## Complains about missing /usr/lib/transcode/export_mjpeg.so
# OUTPUT_CODEC="-y xvid4"       ## No better but works
OUTPUT_CODEC="-y ffmpeg -F mpeg4" ## Recommended

## One pass:
# transcode -i "$INPUT" -x mplayer -o "$OUTPUT" $OUTPUT_CODEC -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $EXTRA_TRANSCODE_OPTS

## Two pass:
# transcode -i "$INPUT" -x vob -o /dev/null $OUTPUT_CODEC -R 1 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $PREVIEW $EXTRA_TRANSCODE_OPTS
# transcode -i "$INPUT" -x vob -o "$OUTPUT" $OUTPUT_CODEC -R 2 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $PREVIEW $EXTRA_TRANSCODE_OPTS
transcode -i "$INPUT" -x mplayer -o /dev/null $OUTPUT_CODEC -R 1 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $PREVIEW $EXTRA_TRANSCODE_OPTS
transcode -i "$INPUT" -x mplayer -o "$OUTPUT" $OUTPUT_CODEC -R 2 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $PREVIEW $EXTRA_TRANSCODE_OPTS

## Notes:
## +1kbps on a 1hr40min video will increase size by 3/4Meg
## 100*60 * 128 / 1024 = 750.0
## 1kbitps * 100minutes*60seconds * 1024k / 8bits / 1024k = 750kbytes
