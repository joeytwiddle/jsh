## If the time is spent reading the stream (not creating it), then this cat will show progress.
## This script assumes dd blocks.  Fortunately it does!
## This script saves a temporary copy of the stream contents, so don't use it if the stream is very long or unbounded.
## If the full contents of the stream is too large, this script is not suitable, since it must temporarily save the stream contents in a file.
## Hmm well it works over networks at least, maybe helped if stdout/err are sent in sync over ssh.
## But it doesn't always work.

if [ "$1" = -size ]
then
	SIZE="$2"; shift; shift
	TMPFILE=
else
	TMPFILE=`jgettmp catwithprogress`
	cat "$@" > "$TMPFILE" || exit 123
	SIZE=`filesize "$TMPFILE"`
fi

BLOCKSIZE=`expr "$SIZE" / 50`
[ "$BLOCKSIZE" -gt 0 ] || BLOCKSIZE=1024 ## Well if size is valid, maybe this should be 1.

SOFAR=0

if [ "$TMPFILE" ]
then cat "$TMPFILE"
else cat
fi |

while true
do

	dd bs="$BLOCKSIZE" count=1 2> /tmp/dd.err

	grep "^0+0" /tmp/dd.err && break
	ADDED=`cat /tmp/dd.err | tail -n 1 | sed 's+ .*++'`
	# SOFAR=`expr $SOFAR + $BLOCKSIZE`
	SOFAR=`expr $SOFAR + $ADDED`
	PERCENTAGE=`expr 100 '*' $SOFAR / $SIZE`
	echo "$SOFAR / $SIZE ($PERCENTAGE%)" >&2

done

[ "$TMPFILE" ] && jdeltmp "$TMPFILE"
