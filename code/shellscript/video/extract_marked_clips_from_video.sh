VIDEOFILE="$1"
CLIPMARKERFILE=/tmp/clipmarkers.txt

CLIPNUM=1

cat "$CLIPMARKERFILE" |

while read IN OUT
do

	echo "IN=$IN OUT=$OUT"

	LENGTH=`echo "$OUT - $IN" | bc` || exit 3

	export CLIPOPTS="-ss $IN -endpos $LENGTH"

	COPY="-oac copy -ovc copy"
	# COPY="-oac lavc -ovc lavc"
	mencoder $COPY $CLIPOPTS "$VIDEOFILE" -o clip$CLIPNUM.avi

	# prepare_for_editing "$VIDEOFILE"
	# mv re_encoded.dv clip$CLIPNUM.dv

	## TODO: left pad CLIPNUM with '0's
	CLIPNUM=`expr $CLIPNUM + 1`

	echo
	echo "------------------------------------------------------------------------------"
	echo

done
