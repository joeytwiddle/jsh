# jsh-ext-depends-ignore: clip
# jsh-ext-depends: dirname mencoder
VIDEOFILE="$1"
CLIPMARKERFILE=/tmp/clipmarkers.txt

OUTPUTDIR=`dirname "$VIDEOFILE"`
if [ ! -w "$OUTPUTDIR" ]
then OUTPUTDIR=/tmp
fi

CLIPNUM=1

cat "$CLIPMARKERFILE" |
grep -v "^#" |

while read IN OUT CLIPNAME
do

	OUTPUTFILE="clip$CLIPNUM.avi"
	[ "$CLIPNAME" ] && OUTPUTFILE="$CLIPNAME.avi"

	echo
	echo "# `curseyellow`Saving clip #$CLIPNUM in $OUTPUTDIR/$OUTPUTFILE`cursenorm`"
	echo "# `curseyellow`inpoint=$IN outpoint=$OUT`cursenorm`"
	echo

	LENGTH=`echo "$OUT - $IN" | bc` || exit 3

	export CLIPOPTS="-ss $IN -endpos $LENGTH"

	COPY="-oac copy -ovc copy"
	# COPY="-oac lavc -ovc lavc"
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=4000"
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=ljpeg" ## Huge!
	# COPY="-oac lavc -ovc lavc -lavcopts vcodec=ffv1:vstrict=-1" ## Huge!
	mencoder $COPY $CLIPOPTS "$VIDEOFILE" -o "$OUTPUTDIR/$OUTPUTFILE"

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
echo "    `basename "$0"` \"$1\""
echo
curseyellow
echo "to extract the adjusted clips."
echo
cursenorm

## CONSIDER: add a bit of script here which asks if you want to re-extract adjusted clips,
## then run an editor, and re-run extraction.
## Also offer a "Don't ask me this again!" option.
