MEMODIR="$JPATH/data/memo"

## TODO:
#  - Allow user to specify their own hash (essentially making memo a hashtable)
#  - Leaves an empty or partial memo file if interrupted
#    We should memo to a temp file and move to memo file when complete
#  - Allow user to specify timeout after which rememo occurs
#  - Allow user to specify quick command which returns non-0 if rememo needed (or a test-rememo command?)

if test "$1" = "-info"; then
	MEMO_SHOW_INFO=true
	shift
fi

if test "$1" = ""; then
	echo "memo <command>..."
	echo "  Caches the output of a command (useful if it takes a long time to run)."
	echo "  Memo will remember the output of <command> in current working directory, and"
	echo "    will redisplay this output on subsequent calls."
	echo "  You may use rememo <cmd> to override the stored output."
	echo "  Todo: -l <time> to specify recalculation after <time> period."
	echo "        Possibly rememodiff which looks for changes since last memoed."
	exit 1
fi

REALPWD=`realpath "$PWD"`
CKSUM=`echo "$*" | md5sum`
NICECOM=`echo "$REALPWD: $@.$CKSUM" | tr " /" "_-" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"

## (MEMOING and REMEMO vars should be combined)
if test -f "$FILE" && test ! "$REMEMO" && test ! "$MEMOING" = "off"
then cat "$FILE"
else rememo "$@"
fi

if test "$MEMO_SHOW_INFO"; then

	TMPF=`jgettmp`
	touch "$TMPF"
	(
		cursecyan
		# echo "as of "`date -r "$FILE"`
		echo "$@"
		TIMEAGO=`datediff -files "$FILE" "$TMPF"`
		echo "as of $TIMEAGO ago."
		cursenorm
	) >&2
	jdeltmp "$TMPF"

fi
