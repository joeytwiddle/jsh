if test "$1" = "--help" || test ! "$1"
then
	# echo "wordpatch <file1> [ -o <file2> ] [ <GNU diff options>... ]"
	echo "wordpatch [ -x ] <file> [ -o <outfile> ] [ <GNU diff options>... ]"
	exit 1
fi

WORDS=-words
if test "$1" = -xwords
then WORDS=-xwords; shift
fi

SRCFILE="$1"
shift

DESTFILE=$SRCFILE
if test "$1" = -o
then
	DESTFILE="$2"
	shift
	shift
fi

SRCFILEENC=`jgettmp "wordpatch: src=$SRCFILE.xescaped"`
DESTFILEENC=`jgettmp "wordpatch: dest=$DESTFILE.xescaped"`

escapenewlines -x "$SRCFILE" > $SRCFILEENC

patch $SRCFILEENC -o $DESTFILEENC "$@" || exit

unescapenewlines -x $DESTFILEENC > "$DESTFILE"

jdeltmp $SRCFILEENC $DESTFILEENC
