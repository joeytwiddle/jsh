MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $@" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"

if test -f "$FILE"; then
  cat "$FILE"
else
  rememo "$@"
fi

cursecyan
echo "As of "`date -r "$FILE"`
cursegrey
