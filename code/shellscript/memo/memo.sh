MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $*" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"

if test -f "$FILE"; then
  cat "$FILE"
  exit 0
else
  rememo "$@"
fi
