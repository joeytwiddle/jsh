# jsh-ext-depends: sed md5sum tty realpath
# jsh-depends-ignore: cursemagenta cursenorm debug
# jsh-depends: memo jdeltmp jgettmpdir jgettmp realpath md5sum error jshwarn
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

## This doesn't work if input is "x | y"
# "$@" | tee "$FILE"

if ! tty >/dev/null
then jshwarn "rememo found no pts on \"$*\".  If different input streams can give different outputs, then memoing should not be employed."
fi

## eval caused problems when one of the args was a URL containing the '&' character
## BUG: can't handle single bracket in filename eg. memo du -sk ./*
## BUG: also can't handle 's in filenames
eval "$@" > $TMPFILE

EXITWAS="$?"
if [ "$EXITWAS" = 0 ]
then
	mv -f $TMPFILE "$FILE"
	cat "$FILE"
else
  [ "$DEBUG" ] && debug "rememo: not caching since command gave exit code $EXITWAS: $*"
	cat $TMPFILE
fi
jdeltmp $TMPFILE
exit "$EXITWAS"
