#!/bin/sh
# @packages faac gpac

require_exes mplayer mencoder faac x264 MP4Box || exit

set -e
# set -x

INFILE="$1"
if [ ! -f "$INFILE" ]
then
cat << !

<options> nice -n 5 reencode_video_to_x264 <video_file>

  Fair quality (defaults):
    LOSS=16 AUDIOQUALITY=50 FPS=23.976

  Video quality:
    LOSS=25

  Low quality (visible artefacts):
    LOSS=35 MONO=1   (see MONO warning below!)

  Low quality alternative:
    LOSS=30 FPS=15 MONO=1

    Beware!  non-standard FPS might confuse some players!

  More options:

    OUTSIZE=720x480
    PREVIEW="-ss 0:01:00 -endpos 0:10"
    OUTFILE="blah.x264"
    MONO=1   Downmix to mono (Beware!  May halve volume if input was mono!)
    X264_OPTIONS="--ratetol 5.0"
      Allows bitrate/filesize to grow by 5% for later scenes which really need it

!
exit 1
fi

[ "$OUTFILE" ] || OUTFILE="$INFILE.x264.mp4"

## TODO: Input size and fps could be obtained from mplayer's output line starting "VIDEO:"

## OUTSIZE should be input size, unless we are scaling with SCALEOPTS
# [ "$OUTSIZE" ] || OUTSIZE=720x480
[ "$FPS" ] || FPS=23.976
# [ "$LOSS" ] || LOSS=26 ## web video quality
[ "$LOSS" ] || LOSS=16 ## reasonable video quality, a tiny bit lossy
# [ "$LOSS" ] || LOSS=12 ## good video quality
# [ "$LOSS" ] || LOSS=8 ## film quality?
# AUDIOQUALITY=40 can create unpleasant distortion
[ "$AUDIOQUALITY" ] || AUDIOQUALITY=50   # 100

# PREVIEW="-ss 0:01:00 -endpos 0:10"
## Not recommended: MOREOPTS="--ratetol 5.0" as it can cause file size to blow out
## --crf already attempts to reduce quality of less-important frames
## However ratetol can be useful for climactic movies, where we expect to need
## a higher bitrate for the end scenes than the earlier parts of the movie.

## Needed for some .flv files (e.g. from YouTube)
fixTooManyPtsError="-nocorrect-pts"

if [ -z "$INSIZE" ]
then
	INSIZE="`getvideoresolution "$INFILE"`"
	debug "Got input resolution: $INSIZE"
fi

[ -z "$OUTSIZE" ] && OUTSIZE="$INSIZE"

## Generate suitable value for SCALEOPTS from OUTSIZE
# e.g. OUTSIZE=640x360 requires SCALEOPTS="scale=640:360,"
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
## By adding $$ we allow two encoding processes to run at once.  However if we
## interrupt before the wav->aac is complete, this uniquely-named file will be
## left there!
## By using the filename, we will clean any tempfile if we rerun the script
## after an interrupted run.  Two encoding processes can still run, provided
## their videos have different names!
# TMPWAVFILE="$INFILE.audiodump.wav.tmp"
## The problem is, the mencoder line we use can't output to files with spaces/quotes.
TMPWAVFILE="$$.audiodump_tmp.wav"

## The temp wav file is pretty large, sometimes larger than the final video!
## We could dump the wav-file to memory.  This is a silly idea on busy
## machines, it can cause a lot of application memory to be pushed to swap!
# targetDir=/dev/shm
## Since the data is written and read linearly, we can just store it on a drive
## with enough space (preferably different from the drive we are reading from).
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

		[ "$MONO" = 1 ] && MPLAYER_AUDIO_OPTS="$MPLAYER_AUDIO_OPTS -af pan=1:0.5:0.5"
		## This eval is only needed to do the 2> redirection inside verbosely!  :P
		## Drop either the 2> redirect or verbosely, and the eval won't be needed.
		verbosely eval "mplayer -noconsolecontrols $fixTooManyPtsError $MPLAYER_AUDIO_OPTS -vc null -vo null -ao pcm:fast:file=$TMPWAVFILE \"$INFILE\" 2>/dev/null" &&
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
## DONE: Warn the user of the above!
if [ "$PREVIEW" ]
then
	if [ -f "$FIFOFILE" ]
	then echo "[WARNING] Re-using previous tmpfile.  If you have changed PREVIEW size then delete $FIFOFILE and re-run!"
	fi
else
	rm -f "$FIFOFILE"
	if ! mkfifo "$FIFOFILE"
	then
		# Some filesystems do not support fifo files!
		# So we will just use a normal file.  That might be best placed in /tmp.
		FIFOFILE="/tmp/`basename "$FIFOFILE"`"
		echo "Warning: Failed to create FIFO.  Will use tmpfile instead: $FIFOFILE"
	fi
fi

OUTPUT_OPTIONS="-nosound -of rawvideo -ofps $FPS -ovc raw -vf $SCALEOPTS""format=i420"
if [ ! -f "$FIFOFILE" ]
then
	verbosely mencoder $PREVIEW $OUTPUT_OPTIONS -o "$FIFOFILE" "$INFILE" >/dev/null &
	# verbosely mplayer $PREVIEW -vo yuv4mpeg "$INFILE" && mv stream.yuv "$FIFOFILE"
	## If we are sending to a file, then we wait for that to finish before we run x264
	if [ ! -e "$FIFOFILE" ] || [ -f "$FIFOFILE" ]
	then wait
	fi
	## NOTE: Alternatively, we could just sleep 5 and assume x264 will never
	## catch up with mencoder.  This might finish faster on multi-processor
	## machines.
fi



### Encode with x264:

## Basic:
verbosely x264 --fps "$FPS" --crf "$LOSS" --input-res "$INSIZE" $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE"

## Readable by most players (Quicktime):
# verbosely x264 --fps "$FPS" --bframes 2 --crf "$LOSS" --subme 6 --analyse p8x8,b8x8,i4x4,p4x4 $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE" --input-res "$INSIZE"

## For 2-pass, replace --crf "$LOSS" with --bitrate and pass number:
# x264 --pass 1 --bitrate 1000 -o <output> <input>
# x264 --pass 2 --bitrate 1000 -o <output> <input>
## Note with YUV input, this will only hit target bitrate if FPS matches input file.

## NOTE: The x264 --progress and --no-psnr options seem to have disappeared!

rm -f "$FIFOFILE"



## Combine audo and video:
verbosely MP4Box -add "$OUTFILE" -add "$AACFILE" -fps "$FPS" "$OUTFILE".with_video

mv -f "$OUTFILE".with_video "$OUTFILE"



if [ "$PREVIEW" = "" ]
then cleanup_audio_files
fi

if find /tmp/ /dev/shm/ -maxdepth 1 -iname "*.wav" | grep .
then echo "The above files are left on your (ram)disk!"
fi

