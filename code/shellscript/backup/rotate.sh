## TODO: What's that oldMEGA business?  Is it kosha?
## TODO: Instead of moving, or deleting, original file, sometimes it may be better to echo -n into it.  (inode business)

if test "$1" = "" || test "$1" = --help
then
	echo "rotate [ -nozip ] [ -max <num> ] <file>"
	echo "  will move <file> to <file>.N"
	echo "  will rotate to ensure no more than <num> + 1 logs."
	echo "  never rotates <file>.0"
	exit 1
fi

ZIP=true
if test "$1" = "-nozip"
then ZIP=; shift
fi

MAX=
if test "$1" = "-max"
then shift; MAX="$1"; shift
fi

FILE="$1"

if test ! "$ZIP"
then
	ZIPCOM=""
	FINALFILE="$FILE"
elif test -f "$FILE"
then
	ZIPCOM="gzip"
	FINALFILE="$FILE.gz"
elif test -d "$FILE"
then
	ZIPCOM="tar cfz $FILE.tgz"
	FINALFILE="$FILE.tgz"
else
	echo "$FILE is not a file or a directory"
	exit 1
fi

if test "$ZIPCOM"
then
	echo "rotate: $ZIPCOM \"$FILE\""
	$ZIPCOM "$FILE" || exit 1
fi

N=0
while test -f "$FINALFILE.$N"
do
	N=`expr "$N" + 1`
done

echo "rotate: mv \"$FINALFILE\" \"$FINALFILE.$N\""
mv "$FINALFILE" "$FINALFILE.$N"

if test "$MAX"
then
	if test "$N" -gt "$MAX"
	then
		echo "Rotating the files..."
		## Start at 1 so 0 is not rotated.
		X=1
		mv "$FINALFILE.$X" "$FINALFILE.$X.oldMEGAbakB4rotate"
		while test "$X" -lt "$N"
		do
			XN=`expr "$X" + 1`
			mv "$FINALFILE.$XN" "$FINALFILE.$X"
			X="$XN"
		done
	fi
fi
