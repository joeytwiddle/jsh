MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
NICECOM=`echo "$REALPWD: $@" | tr " /" "_-" | sed 's+\(........................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"
mkdir -p "$MEMODIR"

"$@" | tee "$FILE"
