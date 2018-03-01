#!/bin/bash
# jsh-depends: require_exes getvideoduration debug
# @packages faac gpac

require_exes mplayer mencoder faac x264 MP4Box filesize getvideoresolution \
  getvideoduration verbosely || exit

set -e
# set -x

INFILE="$1"
if [ ! -f "$INFILE" ]
then
cat << !

<options> reencode_video_to_x264 <video_file>

  Good quality:
    LOSS=15 AUDIOQUALITY=100

  Fair quality (defaults):
    LOSS=20 AUDIOQUALITY=80 FPS=23.976

  Video quality:
    LOSS=25

  Low quality (visible artefacts):
    LOSS=35 MONO=1   (see MONO warning below!)

  Low quality alternative:
    LOSS=30 FPS=15 MONO=1
    (Beware!  non-standard FPS might confuse some players!)

  More options:

    PREVIEW="-ss 0:01:00 -endpos 0:10"
    TARGET_SIZE=100   # for 100Meg file, LOSS ignored
    OUTSIZE=720x480 or easier OUTWIDTH=720
    OUTFILE="blah.x264"   # .avi lost sound, .mkv lost video, .mp4 is ok
    MONO=1   # Downmix to mono (Beware!  May halve volume if input was mono!)
    X264_OPTIONS="--ratetol 5.0"
      # Allows bitrate/filesize to grow by 5% for later action scenes
    TWOPASS=true   # use with TARGET_SIZE; may overshoot (can use >15G of space!)
    ROTATE=1       # 90 deg with mencoder (1 clockwise, 2 anti, 0 and 3 also flip)

!
exit 1
fi

[ -n "$OUTFILE" ] || OUTFILE="$INFILE.x264.mp4"

## TODO: Input size and fps could be obtained from mplayer's output line starting "VIDEO:"

### Defaults:
## OUTSIZE should be input size, unless we are scaling with SCALEOPTS
# [ -n "$OUTSIZE" ] || OUTSIZE=720x480
[ -n "$FPS" ] || FPS=23.976
# [ -n "$LOSS" ] || LOSS=8 ## ridiculous quality?
# [ -n "$LOSS" ] || LOSS=12 ## great quality
# [ -n "$LOSS" ] || LOSS=16 ## good film quality, a tiny bit lossy
[ -n "$LOSS" ] || LOSS=20 ## sensible quality, pretty good but not bloated
# [ -n "$LOSS" ] || LOSS=26 ## web video quality
# AUDIOQUALITY=40 can create unpleasant distortion
[ -n "$AUDIOQUALITY" ] || AUDIOQUALITY=80

# PREVIEW="-ss 0:01:00 -endpos 0:10"
## Not recommended: MOREOPTS="--ratetol 5.0" as it can cause file size to blow out
## --crf already attempts to reduce quality of less-important frames
## However ratetol can be useful for climactic movies, where we expect to need
## a higher bitrate for the end scenes than the earlier parts of the movie.

# tmpDir=.
# tmpDir=/dev/shm
tmpDir=/tmp

## Needed for some .flv files (e.g. from YouTube)
fixTooManyPtsError="-nocorrect-pts"

if [ -z "$INSIZE" ]
then
	INSIZE="`getvideoresolution "$INFILE"`"
	debug "Got input resolution: $INSIZE"
fi

if [ -n "$OUTWIDTH" ]
then
  INWIDTH="`echo "$INSIZE" | sed 's+x.*++'`"
  INHEIGHT="`echo "$INSIZE" | sed 's+.*x++'`"
  OUTHEIGHT=$(( INHEIGHT * OUTWIDTH / INWIDTH / 2 * 2 ))
  # x264 demands a multiple of 2.  Let's force that for width too, just in case!
  OUTWIDTH=$(( OUTWIDTH / 2 * 2 ))
  OUTSIZE="$OUTWIDTH"x"$OUTHEIGHT"
fi

[ -z "$OUTSIZE" ] && OUTSIZE="$INSIZE"

## Generate suitable value for SCALEOPTS from OUTSIZE
# e.g. OUTSIZE=640x360 requires SCALEOPTS="scale=640:360,"
if [ ! "$OUTSIZE" = "$INSIZE" ] && [ -z "$SCALEOPTS" ]
then
	SCALEOPTS="scale=`echo "$OUTSIZE" | tr 'x' ':'`,"
	## mplayer will scale the video down, so the insize to x264 will change:
	INSIZE="$OUTSIZE"
fi

if [ -n "$ROTATE" ]
then
	OUTWIDTH="`echo "$OUTSIZE" | beforefirst "x"`"
	OUTHEIGHT="`echo "$OUTSIZE" | afterfirst "x"`"
	INWIDTH="`echo "$INSIZE" | beforefirst "x"`"
	INHEIGHT="`echo "$INSIZE" | afterfirst "x"`"
	# For +/-90, but not for 180
	# Below here, INSIZE is only used by x264 as the size mencoder outputs.
	OUTSIZE="$OUTHEIGHT"x"$OUTWIDTH"
	INSIZE="$INHEIGHT"x"$INWIDTH"
	MENCODER_VIDEO_OPTS="$MENCODER_VIDEO_OPTS -vf rotate=$ROTATE"
fi

## Be gentle:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

# In seconds
INPUT_VIDEO_DURATION=`getvideoduration "$INFILE" | sed 's+\..*++'`

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
## E.g. 2.0G for a feature-length movie.  Set tmpDir above.
## We could dump the wav-file to memory (/dev/shm).  But this is a bad idea on
## busy machines, it can cause a lot of application memory to be pushed to swap!
## Since the data is written and read linearly, we can just store it on a drive
## with enough space (preferably different from the drive we are reading from).
if [ -w "$tmpDir" ]
then
	WAVFILE="$tmpDir"/"`basename "$WAVFILE"`"
	TMPWAVFILE="$tmpDir"/"`basename "$TMPWAVFILE"`"
	## I won't do this unles $AACFILE is cleaned up every time.  It might leave unwanted files around!
	# AACFILE="$tmpDir"/"`basename "$AACFILE"`"
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
		## We also need a full audio file so we can correctly calculate
		## ENCODING_RATE from TARGET_SIZE later.

		[ "$MONO" = 1 ] && MPLAYER_AUDIO_OPTS="$MPLAYER_AUDIO_OPTS -af pan=1:0.5:0.5"
		## This eval is only needed to do the 2> redirection inside verbosely!  :P
		## Drop either the 2> redirect or verbosely, and the eval won't be needed.
		verbosely eval "mplayer -noconsolecontrols $fixTooManyPtsError $MPLAYER_AUDIO_OPTS -vc null -vo null -ao pcm:fast:file=$TMPWAVFILE \"$INFILE\" >/dev/null 2>/dev/null" &&
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
if [ -n "$PREVIEW" ]
then
	if [ -f "$FIFOFILE" ]
	then echo "[WARNING] Re-using previous tmpfile.  If you have changed PREVIEW size then delete $FIFOFILE and re-run!"
	fi
else
	rm -f "$FIFOFILE"
	## TWOPASS cannot use a fifo until we move the below mencoder call into a function, so we can run it again for the second pass.
	if [ -n "$TWOPASS" ] || ! mkfifo "$FIFOFILE"
	then
		# Some filesystems do not support fifo files!
		# So we will just use a normal file.
		FIFOFILE="$tmpDir/`basename "$FIFOFILE"`"
		echo "Using tmpfile instead of fifo: $FIFOFILE"
	fi
fi

OUTPUT_OPTIONS="-nosound -of rawvideo -ofps $FPS -ovc raw -vf $SCALEOPTS""format=i420 $MENCODER_VIDEO_OPTS"
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

if [ -n "$TARGET_SIZE" ]
then
	# In kilobytes
	AUDIO_SIZE=$(( $(filesize "$AACFILE") / 1024 ))
	SIZE_LEFT=$(( TARGET_SIZE*1024 - AUDIO_SIZE ))
	BITRATE=$(( SIZE_LEFT*8 / INPUT_VIDEO_DURATION ))
	ENCODING_RATE="--bitrate $BITRATE"
else
	ENCODING_RATE="--crf $LOSS"
fi

FPSINT="`echo "$FPS" | sed 's+\..*++'`"
numFrames=$(( INPUT_VIDEO_DURATION * FPSINT ))
echo "At least $numFrames frames to encode..."

if [ -n "$TWOPASS" ]
then

	## For 2-pass, replace --crf "$LOSS" with --bitrate and pass number:
	verbosely x264 --pass 1 --bitrate $BITRATE --fps "$FPS" --input-res "$INSIZE" $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE"
	verbosely x264 --pass 2 --bitrate $BITRATE --fps "$FPS" --input-res "$INSIZE" $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE"
	## Note with YUV input, this will only hit target bitrate if FPS matches input file.

else

	## Basic:
	verbosely x264 $ENCODING_RATE --fps "$FPS" --input-res "$INSIZE" $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE"

fi

## Readable by most players (Quicktime):
# verbosely x264 --fps "$FPS" --bframes 2 $ENCODING_RATE --subme 6 --analyse p8x8,b8x8,i4x4,p4x4 $X264_OPTIONS -o "$OUTFILE" "$FIFOFILE" --input-res "$INSIZE"

## NOTE: The x264 --progress and --no-psnr options seem to have disappeared!

rm -f "$FIFOFILE"



## Combine audo and video:
verbosely MP4Box -add "$OUTFILE" -add "$AACFILE" -fps "$FPS" "$OUTFILE".with_video

mv -f "$OUTFILE".with_video "$OUTFILE"



if [ -z "$PREVIEW" ]
then cleanup_audio_files
fi

rm -f x264_2pass.log x264_2pass.log.mbtree

if find $tmpDir/ /dev/shm/ -maxdepth 1 -iname "*.wav" | grep .
then echo "The above files are left on your (ram)disk!"
fi

