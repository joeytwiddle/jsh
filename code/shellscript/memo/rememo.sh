# jsh-depends: memo jdeltmp jgettmpdir jgettmp realpath md5sum error
## TODO: delete the memoed file if interrupted
##       (eg. (optionally delete it,) memo to elsewhere, then move into correct place if successful)

# [ "$DEBUG" ] && debug "REMEMO:   `cursemagenta`$*`cursenorm`"

. jgettmpdir -top
MEMODIR=$TOPTMP/memo
REALPWD=`realpath "$PWD"`
CKSUM=`echo "$REALPWD/$*" | md5sum`
NICECOM=`echo "$CKSUM..$*..$REALPWD" | tr " \n/" "__+" | sed 's+\(................................................................................\).*+\1+'`
FILE="$MEMODIR/$NICECOM.memo"
mkdir -p "$MEMODIR"

[ "$DEBUG" ] && debug "REMEMO:   `cursemagenta`$NICECOM`cursenorm`"

TMPFILE=`jgettmp tmprememo`

# "$@" | tee "$FILE"
## Now passes back appropriate exit code: =)
eval "$@" > $TMPFILE
EXITWAS="$?"
if [ "$EXITWAS" = 0 ]
then
	mv -f $TMPFILE "$FILE"
	cat "$FILE"
else
  [ "$DEBUG" ] && debug "rememo: not caching since command gave exit code $EXITWAS: $*"
fi
jdeltmp $TMPFILE
exit "$EXITWAS"
