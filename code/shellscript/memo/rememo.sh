## TODO: delete the memoed file if interrupted
##       (eg. could delete it, memo to elsewhere, then move into correct place if successful)

. jgettmpdir -top
MEMODIR=$TOPTMP/memo
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
