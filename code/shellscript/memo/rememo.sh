MEMODIR="$JPATH/data/memo"
mkdir -p "$MEMODIR"

COM="$*";
# It appears PWD doesn't work on nutayruk
NICECOM=`echo "$PWD: $COM" | tr " /" "_-"`
FILE="$MEMODIR/$NICECOM.memo"

$COM | tee "$FILE"
# $COM > "$FILE"
# cat "$FILE"
exit 0
