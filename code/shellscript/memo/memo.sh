MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $@" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"

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
