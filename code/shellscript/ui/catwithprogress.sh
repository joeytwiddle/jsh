## If the full contents of the stream is not too large,
## and the time is spent reading the stream (not creating it),
## then this cat will show progress.
## This script assumes dd blocks.
## Fortunately it does!

TMPFILE=`jgettmp catwithprogress`

cat "$@" > "$TMPFILE" || exit 123

SIZE=`filesize "$TMPFILE"`
BLOCKSIZE=`expr "$SIZE" / 50`
[ "$BLOCKSIZE" -gt 0 ] || BLOCKSIZE=1024

SOFAR=0

cat "$TMPFILE" |

while true
do

	dd bs="$BLOCKSIZE" count=1 2> /tmp/dd.err

	grep "^0+0" /tmp/dd.err && break

	SOFAR=`expr $SOFAR + $BLOCKSIZE`
	PERCENTAGE=`expr 100 '*' $SOFAR / $SIZE`
	echo "$SOFAR / $SIZE ($PERCENTAGE%)" >&2

done

jdeltmp "$TMPFILE"
