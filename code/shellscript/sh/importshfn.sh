# . importshfn <shellscriptname>

SCRIPT=`jwhich inj "$1"`

if test "$SCRIPT" = ""; then
	echo "importshfn: no such script: $1" > /dev/stderr
	exit 1
fi

TMPFILE=`jgettmp`

makeshfunction "$SCRIPT" > $TMPFILE

. $TMPFILE

jdeltmp $TMPFILE
