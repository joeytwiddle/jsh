MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $*" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"
mkdir -p "$MEMODIR"

"$@" | tee "$FILE"
