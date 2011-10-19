#!/bin/sh
# @packages faac gpac

# set -x
set -e

INFILE="$1"
if [ ! -f "$INFILE" ]
then
cat << !

nice -n 5 reencode_video_to_x264 <video_file>

  Default vars:

    FPS=23.976
    LOSS=16
    AUDIOQUALITY=50

  Optional vars:

    OUTSIZE=720x480
    PREVIEW="-ss 0:01:00 -endpos 0:10"
    SCALEOPTS="scale=480:320,"
      (no longer needed - automatically derived from OUTSIZE)

!
exit 1
fi
[ "$OUTFILE" ] || OUTFILE="$INFILE.x264.mp4"

## TODO: Input size and fps could be obtained from mplayer's output line starting "VIDEO:"

## OUTSIZE should be input size, unless we are scaling with SCALEOPTS
# [ "$OUTSIZE" ] || OUTSIZE=720x480
[ "$FPS" ] || FPS=23.976
[ "$LOSS" ] || LOSS=26 ## web quality
# [ "$LOSS" ] || LOSS=16 ## reasonable, a tiny bit lossy
# [ "$LOSS" ] || LOSS=12 ## video quality
# [ "$LOSS" ] || LOSS=8 ## film quality?
[ "$AUDIOQUALITY" ] || AUDIOQUALITY=50   # 100

## My current settings (override existing - should not be here!)
# OUTSIZE=640x360 ; SCALEOPTS="scale=640:360,"
# OUTSIZE=576x320 ; SCALEOPTS="scale=576:320,"
# OUTSIZE=640x272 ; SCALEOPTS="scale=640:272,"
# OUTSIZE=560x304 ; SCALEOPTS="scale=560:304,"
# OUTSIZE=448x256 ; SCALEOPTS="scale=448:256,"
# PREVIEW="-ss 0:01:00 -endpos 0:10"
# LOSS=20
# AUDIOQUALITY=40
## Not recommended: MOREOPTS="--ratetol 5.0"

## Needed for some .flv files (e.g. from YouTube)
fixTooManyPtsError="-nocorrect-pts"

if [ -z "$INSIZE" ]
then
	INSIZE="`getvideoresolution "$INFILE"`"
	debug "Got input resolution: $INSIZE"
fi

[ -z "$OUTSIZE" ] && OUTSIZE="$INSIZE"

if [ ! "$OUTSIZE" = "$INSIZE" ] && [ ! "$SCALEOPTS" ]
then
	SCALEOPTS="scale=`echo "$OUTSIZE" | tr x :`,"
	## mplayer will scale the video down, so the insize to x264 will change:
	INSIZE="$OUTSIZE"
fi

cleanup_audio_files() {
	del audiodump.wav audiodump.aac
}

if [ ! -f audiodump.aac ]
then
	## BUG TODO: file is not deleted if mplayer was interrupted, so a second attempt may use an incomplete audio file.  We could solve this by renaming the file on success.
	if [ ! -f audiodump.wav ]
	# then verbosely mplayer -ao pcm -vc null -vo null "$INFILE"
	then
		## We could pass $PREVIEW here, then the audio of the preview comes out right.
		## But then the user will have to encode the whole audio file again later.
		## I decided it was easier if we only encode the audio once, then nobody
		## has to worry about whether the audiodump.aac file is out-of-date or not.
		verbosely eval "mplayer -noconsolecontrols $fixTooManyPtsError -vc null -vo null -ao pcm:fast \"$INFILE\" 2>/dev/null"
		# | grep -u "A:"
		# | fromline 'Starting playback...'
		## The two lines above can work but not realtime.  The emit nothing, then finally dump the whole filtered stream in one go.
		## It's as if the streams were heavily buffered.
	fi
	verbosely faac -q "$AUDIOQUALITY" --mpeg-vers 4 audiodump.wav &&
	rm -f audiodump.wav
fi


### Output in a nice format for x264:

## When experimenting with a preview, we want tmp.fifo.yuv to be a file, so we
## won't need to re-create it each time, but when doing a whole movie we want
## it to be a fifo.
## NOTE: If you change the PREVIEW parameters, then you must delete
## tmp.fifo.yuv yourself, to re-create the new size version.
if [ ! "$PREVIEW" ]
then
	rm -f tmp.fifo.yuv
	mkfifo tmp.fifo.yuv
fi

OUTPUT_OPTIONS="-nosound -of rawvideo -ofps $FPS -ovc raw -vf $SCALEOPTS""format=i420"
if [ ! -f tmp.fifo.yuv ]
then
	verbosely mencoder $PREVIEW $OUTPUT_OPTIONS -o tmp.fifo.yuv "$INFILE" >/dev/null &
	# verbosely mplayer $PREVIEW -vo yuv4mpeg "$INFILE" && mv stream.yuv tmp.fifo.yuv
	( [ ! -e tmp.fifo.yuv ] || [ -f tmp.fifo.yuv ] ) && wait
fi

## The x264 --progress --no-psnr options seem to have disappeared!



### Encode with x264:

## Basic:
verbosely x264 --fps "$FPS" --crf "$LOSS" -o "$OUTFILE" tmp.fifo.yuv --input-res "$INSIZE"

## Readable by most players (Quicktime):
# verbosely x264 --fps "$FPS" --bframes 2 --crf "$LOSS" --subme 6 --analyse p8x8,b8x8,i4x4,p4x4 $MOREOPTS -o "$OUTFILE" tmp.fifo.yuv --input-res "$INSIZE"

rm -f tmp.fifo.yuv



## Combine audo and video:
verbosely MP4Box -add "$OUTFILE" -add audiodump.aac -fps "$FPS" "$OUTFILE".with_video

mv -f "$OUTFILE".with_video "$OUTFILE"



# cleanup_audio_files

