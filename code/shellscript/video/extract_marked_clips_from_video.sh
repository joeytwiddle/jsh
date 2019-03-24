#!/bin/sh

# jsh-ext-depends: dirname mencoder
# jsh-ext-depends-ignore: clip

VIDEOFILE="$1"; shift
CLIPMARKERFILE=/tmp/clipmarkers.txt

OUTPUTDIR=`dirname "$VIDEOFILE"`
if [ ! -w "$OUTPUTDIR" ]
then OUTPUTDIR="$PWD"
fi
if [ ! -w "$OUTPUTDIR" ]
then OUTPUTDIR=/tmp
fi
if [ "$EXTRACT_IN" ]
then OUTPUTDIR="$EXTRACT_IN"
fi

## If this aspect ratio is incorrect, the video will encode with this resolution, but mplayer will set the correct aspect ratio when the video plays.
## Ratio 4:3
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=640:480"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=720:480"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=800:600"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1024:768"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1280:960"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1365:1024"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1440:1080"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1920:1440"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=2560:1920"
## Ratio 16:9
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=640:360"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=720:405"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=800:450"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1024:576"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1280:720" # HD Ready
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1365:768"
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=1920:1080" # Full HD
# EXTRA_OPTS="$EXTRA_OPTS -vf scale=2560:1440"

## Be gentle:
which renice >/dev/null && renice -n 15 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

CLIPNUM=1

cat "$CLIPMARKERFILE" |
grep -v "^#" |

while read IN OUT CLIPNAME
do

	if [ -n "$CLIPNAME" ]
	then FILENAME_EXTRA="$CLIPNAME"
	else FILENAME_EXTRA="clip${CLIPNUM}"
	fi
	OUTPUTFILE="$(echo "$VIDEOFILE" | sed "s:\(.*\)\.:\1.${FILENAME_EXTRA}.:")"
	if [ "$OUTPUTFILE" = "$VIDEOFILE" ]
	then
		echo "Output filename is the same as video filename! OUTPUTFILE=$OUTPUTFILE"
		exit 1
	fi

	echo
	echo "# `curseyellow`Saving clip #$CLIPNUM in $OUTPUTDIR/$OUTPUTFILE`cursenorm`"
	echo "# `curseyellow`inpoint=$IN outpoint=$OUT`cursenorm`"
	echo

	LENGTH=`echo "$OUT - $IN" | bc` || exit 3

	CLIPOPTS="-ss $IN -endpos $LENGTH"

	# COPY="-oac copy -ovc copy" ## Fastest, probably preferable, but initial frames can be messy and sometimes audio codec will not allow it.
	COPY="-oac pcm -ovc copy" ## Fast but fat.  With some formats, -oac copy fails but we can use -oac pcm.
	# COPY="-oac lavc -ovc lavc" ## Slow, re-encodes both audio and video, but initial frames are fine.
	# COPY="-oac lavc -lavcopts abitrate=224 -ovc lavc -ofps 8 -vf scale=200:-2"
	# COPY="-oac lavc -srate 32000 -lavcopts vbitrate=40 -ovc lavc -ofps 8 -vf scale=320:-2"
	# COPY="-oac lavc -srate 48000 -lavcopts vbitrate=80 -ovc lavc -ofps 10 -vf scale=480:-2"
	# COPY="-oac lavc -srate 48000 -ovc lavc -lavcopts abitrate=224:vbitrate=500 -ofps 20 -vf scale=480:-2" ## A good all-round re-encoding
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=4000" ## Huge!
	# COPY="-oac lavc -ovc lavc -srate 48000 -fps 20 -ofps 30 -lavcopts abitrate=224:vbitrate=800"
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=ljpeg" ## Huge!
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=ffv1:vstrict=-1" ## Huge!
	# COPY="-oac lavc -ovc copy" ## Large

	# verbosely mencoder "$@" $COPY $CLIPOPTS $MENCODER_OPTIONS "$VIDEOFILE" -o "$OUTPUTDIR/$OUTPUTFILE"
	verbosely ffmpeg -ss "$IN" -t "$LENGTH" -i "$VIDEOFILE" -c copy -avoid_negative_ts make_zero -y "$OUTPUTDIR/$OUTPUTFILE"
	# verbosely avconv -ss "$IN" -i "$VIDEOFILE" -t "$LENGTH" -c copy "$OUTPUTDIR/$OUTPUTFILE"

	## NOTE that the following docker calls only work if the target files are specified in or below the current folder (not absolute)

	## Copy video stream directly.  This is very fast, but sometimes doesn't work.
	# verbosely docker run -v "$PWD":/mounted jrottenberg/ffmpeg \
	#     -y -ss "$IN" -i "/mounted/$VIDEOFILE" -t "$LENGTH" -c copy "/mounted/$OUTPUTFILE"

	## Reencoding is slower, but a good alternative if copying doesn't work

	## As noted in https://superuser.com/a/1259172/52910, and confirmed in my tests, the veryfast preset creates smaller files in a shorter time!

	## For 400p, or for a beautiful output, better use crf 18-24
	## For 720p, and some loss, we can use crf 24-30
	## The default crf is 23.  Sane values lie from 19-28.  Entire range is 0-51.
	## Since we switched to using veryfast, we should subtract about 4 from the CRF we would use for medium.
	## That should produce the same quality output, of the same size, but in a shorter time!

	echo "[extract_marked_clips_from_video] OUTPUTFILE: $OUTPUTFILE"

	# verbosely time docker run -v "$PWD":/mounted jrottenberg/ffmpeg \
	#     -y -ss "$IN" -i "/mounted/$VIDEOFILE" -t "$LENGTH" \
	#     -stats \
	#     -c:v libx264 -c:a copy \
	#     $EXTRA_OPTS \
	#     -tune film \
	#     -preset veryfast \
	#     -crf 20 \
	#     "/mounted/$OUTPUTFILE"

	## Without docket
	## For some reason this one never goes on to the second clip O_o
	## It appears that stdin is broken.  Even when it does go to the second clip, the second clip has no start or end time.
	# verbosely ffmpeg \
	#     -y -ss "$IN" -i "$VIDEOFILE" -t "$LENGTH" \
	#     -stats \
	#     -c:v libx264 -c:a copy \
	#     $EXTRA_OPTS \
	#     -tune film \
	#     -preset veryfast \
	#     -crf 26 \
	#     "$OUTPUTDIR/$OUTPUTFILE"

	## It will often produce 20% higher bitrate than the one we specify

	## OK quality: -preset fastest -b 600k \
	## Great quality: -preset medium -b 800k \

	# verbosely time docker run -v "$PWD":/mounted jrottenberg/ffmpeg \
	#     -y -ss "$IN" -i "/mounted/$VIDEOFILE" -t "$LENGTH" \
	#     -stats \
	#     -c:v libx265 -pix_fmt yuv420p10 \
	#     $EXTRA_OPTS \
	#     -preset fastest \
	#     -b 600k \
	#     -f mp4 \
	#     "/mounted/$OUTPUTFILE"

	## The docker mounts output a file owned by root:root, so let's fix that
	verbosely sudo chown "$(id -un):$(id -gn)" "$OUTPUTFILE"

	## We can also try setting the quality level: -crf 22

	# prepare_for_editing "$VIDEOFILE"
	# mv re_encoded.dv clip$CLIPNUM.dv

	## TODO: left pad CLIPNUM with '0's
	CLIPNUM=`expr $CLIPNUM + 1`

	echo
	echo "------------------------------------------------------------------------------"

done

curseyellow
echo
echo "Clips were saved in: `realpath "$OUTPUTDIR"`"
echo
echo "If you need to adjust the clip points, edit the file:"
cursenorm
echo
echo "    $CLIPMARKERFILE"
echo
curseyellow
echo "and then re-run:"
cursenorm
echo
echo "    `basename "$0"` \"$VIDEOFILE\""
echo
curseyellow
echo "to extract the adjusted clips."
echo
cursenorm

## CONSIDER: add a bit of script here which asks if you want to re-extract adjusted clips,
## then run an editor, and re-run extraction.
## Also offer a "Don't ask me this again!" option.
