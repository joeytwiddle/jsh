MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $@" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"

if test "$1" = ""; then
	echo "memo <command>..."
	echo "  Caches the output of a command which takes a long time to run!"
	echo "  Memo will remember the output of <command> in current working directory, and"
	echo "    will redisplay this output on subsequent calls."
	echo "  You may use rememo <cmd> to override the stored output."
	echo "  Todo: -l <time> to specify recalculation after <time> period."
	echo "        Possibly rememodiff which looks for changes since last memoed."
	exit 1
fi

if test -f "$FILE"; then
  cat "$FILE"
else
  rememo "$@"
fi

TMPF=`jgettmp`
touch "$TMPF"
(
	cursecyan
	# echo "as of "`date -r "$FILE"`
	echo "$@"
	echo "as of "`datediff "$FILE" "$TMPF"`" ago."
	cursenorm
) >> /dev/stderr
jdeltmp "$TMPF"
