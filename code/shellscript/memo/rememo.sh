MEMODIR="$JPATH/data/memo"
REALPWD=`realpath "$PWD"`
CKSUM=`echo "$*" | md5sum`
NICECOM=`echo "$REALPWD: $@.$CKSUM" | tr " /" "_-" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"
mkdir -p "$MEMODIR"

# "$@" | tee "$FILE"
## Now passes back appropriate exit code: =)
"$@" > "$FILE"
EXITWAS="$?"
cat "$FILE"
exit "$EXITWAS"
