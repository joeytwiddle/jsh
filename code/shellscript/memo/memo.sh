MEMODIR="$JPATH/data/memo"

if test "$1" = "-info"; then
	MEMO_SHOW_INFO=true
	shift
fi

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

REALPWD=`realpath "$PWD"`
CKSUM=`echo "$*" | md5sum`
NICECOM=`echo "$REALPWD: $@.$CKSUM" | tr " /" "_-" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"

if test -f "$FILE"; then
  cat "$FILE"
else
  rememo "$@"
fi

if test "$MEMO_SHOW_INFO"; then

	TMPF=`jgettmp`
	touch "$TMPF"
	(
		cursecyan
		# echo "as of "`date -r "$FILE"`
		echo "$@"
		echo "as of "`datediff "$FILE" "$TMPF"`" ago."
		cursenorm
	) >&2
	jdeltmp "$TMPF"

fi
