#!/bin/sh
# @packages faac gpac

require_exes mplayer mencoder faac x264 MP4Box || exit

# set -x
set -e

INFILE="$1"
if [ ! -f "$INFILE" ]
then
cat << !

nice -n 5 reencode_video_to_x264 <video_file>

  Fair quality (defaults):
    LOSS=16 AUDIOQUALITY=50 FPS=23.976

  Video quality:
    LOSS=25 AUDIOQUALITY=50 FPS=20

  Low quality (some visible artefacts):
    LOSS=35 AUDIOQUALITY=50 FPS=15

  Optional vars:

    OUTSIZE=720x480
    PREVIEW="-ss 0:01:00 -endpos 0:10"

!
exit 1
fi
[ "$OUTFILE" ] || OUTFILE="$INFILE.x264.mp4"

## TODO: Input size and fps could be obtained from mplayer's output line starting "VIDEO:"

## OUTSIZE should be input size, unless we are scaling with SCALEOPTS
# [ "$OUTSIZE" ] || OUTSIZE=720x480
[ "$FPS" ] || FPS=23.976
# [ "$LOSS" ] || LOSS=26 ## web quality
[ "$LOSS" ] || LOSS=16 ## reasonable, a tiny bit lossy
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
# AUDIOQUALITY=40 can create unpleasant distortion
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
	SCALEOPTS="scale=`echo "$OUTSIZE" | tr 'x' ':'`,"
	## mplayer will scale the video down, so the insize to x264 will change:
	INSIZE="$OUTSIZE"
fi

## We want to keep temp audio files associated with their source file, so multiple encodes will not collide.
WAVFILE="$INFILE.audio.wav"
AACFILE="$INFILE.audio.aac"
## But mplayers file= is not safe to use if $INFILE contains spaced, so we use a tmpfile for that:
TMPWAVFILE="$$.audiodump.wav.tmp"

## The temp wav file is pretty large, sometimes larger than the final video!
## Dump the wav-file to memory?  This is silly, it can cause a lot of
## application memory to be pushed to swap!
# targetDir=/dev/shm
## Since the data is written and read linearly, we really want to store it on a
## different drive from the one currently in use, and with lots of space.
targetDir=/tmp
if [ -w "$targetDir" ]
then
	WAVFILE="$targetDir"/"`basename "$WAVFILE"`"
	TMPWAVFILE="$targetDir"/"`basename "$TMPWAVFILE"`"
	## I won't do this unles $AACFILE is cleaned up every time.  It might leave unwanted files around!
	# AACFILE="$targetDir"/"`basename "$AACFILE"`"
	## In fact TODO: if interrupted, the current script might leave incomplete $OUTFILE or $FIFOFILE visible in the videos' folder, or .wav files HIDDEN in /dev/shm.  If detected, the user should at least be warned!
fi

cleanup_audio_files() {
	rm -f "$WAVFILE" "$AACFILE"
}

if [ ! -f "$AACFILE" ]
then
	## DONE: file is not deleted if mplayer was interrupted, so a second attempt may use an incomplete audio file.  We could solve this by renaming the file on success.
	if [ ! -f "$WAVFILE" ]
	# then verbosely mplayer -ao pcm -vc null -vo null "$INFILE"
	then
		## We could pass $PREVIEW here, then the audio of the preview comes out right.
		## But then the user will have to encode the whole audio file again later.
		## I decided it was easier if we only encode the audio once, then nobody
		## has to worry about whether the $AACFILE file is out-of-date or not.
		## This does mean preview audio comes out wrong.

		## This eval is only needed to do the 2> redirection inside verbosely!  :P
		## Drop either the 2> redirect or verbosely, and the eval won't be needed.
		verbosely eval "mplayer -noconsolecontrols $fixTooManyPtsError -vc null -vo null -ao pcm:fast:file=$TMPWAVFILE \"$INFILE\" 2>/dev/null" &&
		mv -f "$TMPWAVFILE" "$WAVFILE"
	fi
	verbosely faac -q "$AUDIOQUALITY" --mpeg-vers 4 -o "$AACFILE" "$WAVFILE" &&
	rm -f "$WAVFILE"
fi


### Output in a nice format for x264:

## In case we are using PREVIEW, we select a FIFOFILE which we can re-use on successive runs.
## Avoids collisions but not re-usable: FIFOFILE="tmp.fifo.yuv.$$"
FIFOFILE="$INFILE".tmp.fifo.yuv
## NOTE: If you change the PREVIEW parameters, then you must delete
## the FIFOFILE yourself, to re-create the new size version.
## TODO: Warn the user of the above!
if [ ! "$PREVIEW" ]
then
	rm -f "$FIFOFILE"
	mkfifo "$FIFOFILE"
fi

OUTPUT_OPTIONS="-nosound -of rawvideo -ofps $FPS -ovc raw -vf $SCALEOPTS""format=i420"
if [ ! -f "$FIFOFILE" ]
then
	verbosely mencoder $PREVIEW $OUTPUT_OPTIONS -o "$FIFOFILE" "$INFILE" >/dev/null &
	# verbosely mplayer $PREVIEW -vo yuv4mpeg "$INFILE" && mv stream.yuv "$FIFOFILE"
	## If we are sending to a file, then we wait for that to finish before we run x264
	## NOTE: Alternatively, we could just sleep 5 and assume x264 will never
	## catch up with mencoder.  This might finish faster result on
	## multi-processor machines.
	if [ ! -e "$FIFOFILE" ] || [ -f "$FIFOFILE" ]
	then wait
	fi
fi

## The x264 --progress --no-psnr options seem to have disappeared!



### Encode with x264:

## Basic:
verbosely x264 --fps "$FPS" --crf "$LOSS" -o "$OUTFILE" "$FIFOFILE" --input-res "$INSIZE"

## Readable by most players (Quicktime):
# verbosely x264 --fps "$FPS" --bframes 2 --crf "$LOSS" --subme 6 --analyse p8x8,b8x8,i4x4,p4x4 $MOREOPTS -o "$OUTFILE" "$FIFOFILE" --input-res "$INSIZE"

rm -f "$FIFOFILE"



## Combine audo and video:
verbosely MP4Box -add "$OUTFILE" -add "$AACFILE" -fps "$FPS" "$OUTFILE".with_video

mv -f "$OUTFILE".with_video "$OUTFILE"



if [ "$PREVIEW" = "" ]
then cleanup_audio_files
fi

if find /dev/shm -iname "*.wav" | grep .
then echo "The above files are left on your ramdisk!"
fi

