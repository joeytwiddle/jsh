# jsh-depends: memo jdeltmp jgettmpdir jgettmp realpath md5sum error
## TODO: delete the memoed file if interrupted
##       (eg. (optionally delete it,) memo to elsewhere, then move into correct place if successful)

. jgettmpdir -top
MEMODIR=$TOPTMP/memo
REALPWD=`realpath "$PWD"`
CKSUM=`echo "$*" | md5sum`
NICECOM=`echo "$REALPWD: $@.$CKSUM" | tr " /" "_-" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"
mkdir -p "$MEMODIR"

TMPFILE=`jgettmp tmprememo:$*`

# "$@" | tee "$FILE"
## Now passes back appropriate exit code: =)
eval "$@" > $TMPFILE
EXITWAS="$?"
if [ ! "$EXITWAS" = 0 ]
then
  error "memo: not caching since command gave exit code $EXITWAS: $*"
  jdeltmp $TMPFILE
  exit "$EXITWAS"
fi
mv $TMPFILE "$FILE"
cat "$FILE"
jdeltmp $TMPFILE
exit "$EXITWAS"
