if test "$1" = "--help"
then
	echo "worddiff <file1> <file2> [ <GNU diff options>... ]"
	echo "  Produces a diff of the xescaped versions of file1 and file2."
	echo "  These formats have '\\'s and '\\n's slash-escaped, and words, whitespace,"
	echo "  and special characters on separate lines, providing a higher-resolution diff."
	exit 1
fi

FILEA="$1"
FILEB="$2"
shift
shift

FILEAX=`jgettmp "worddiff: $FILEA.xescaped"`
FILEBX=`jgettmp "worddiff: $FILEB.xescaped"`

escapenewlines -x "$FILEA" > $FILEAX
escapenewlines -x "$FILEB" > $FILEBX

diff $FILEAX $FILEBX "$@"
