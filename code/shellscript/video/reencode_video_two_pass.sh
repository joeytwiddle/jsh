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

    The automatic calculation of VIDEO_BITRATE from LENGTH_IN_SECONDS tends to
    produce videos in the range 670-700 Mb.  Maybe the algorithm can be
    improved to move closer to the latter...

!
exit 1
fi

INPUT="$1"
OUTPUT="$INPUT.reencoded.avi"

## Delays (pads at start) audio by 6 frames:
# EXTRA_TRANSCODE_OPTS="-D -6 $EXTRA_TRANSCODE_OPTS"

# del transcode_out.avi
rm -f ./stream.yuv

TARGET_SIZE=700
if [ ! "$AUDIO_BITRATE" ]
then
	jshinfo "Defaulting AUDIO_BITRATE of output to 48 kilobits per second."
	AUDIO_BITRATE=48
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

## One pass:
# transcode -i "$INPUT" -x mplayer -o "$OUTPUT" -y ffmpeg,mjpeg -F mpeg4 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $EXTRA_TRANSCODE_OPTS

## Two pass:
transcode -i "$INPUT" -x mplayer -o /dev/null -y ffmpeg,mjpeg -F mpeg4 -R 1 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $EXTRA_TRANSCODE_OPTS
transcode -i "$INPUT" -x mplayer -o "$OUTPUT" -y ffmpeg,mjpeg -F mpeg4 -R 2 -b "$AUDIO_BITRATE" -w "$VIDEO_BITRATE" $EXTRA_TRANSCODE_OPTS

## Notes:
## +1kbps on a 1hr40min video will increase size by 3/4Meg
## 100*60 * 128 / 1024 = 750.0
## 1kbitps * 100minutes*60seconds * 1024k / 8bits / 1024k = 750kbytes
