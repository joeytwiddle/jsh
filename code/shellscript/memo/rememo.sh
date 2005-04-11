# jsh-ext-depends: sed md5sum tty realpath
# jsh-depends-ignore: cursemagenta cursenorm debug
# jsh-depends: memo jdeltmp jgettmpdir jgettmp realpath md5sum error jshwarn

## TODO: I think md5sum is more CPU intensive than cksum, so we should probably use the latter.  The only reason is so that really long lines which we have to shorted in order to make files, might have different parameters beyond the clipped point, so we must somehow include these.

## TODO: Useful realisation.
##       In all cases where we have had to start using eval
##       (eg. because we want to |)
##       (and which sometimes breaks because of eval)
##       we can actually choose to eval /outside/ of the script, by passing eval "<command>" in.
##       So internal evals are not neccessary.

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

if ! tty >/dev/null && [ ! "$IKNOWIDONTHAVEATTY" ]
then jshwarn "rememo found no pts on \"$*\".  If different input streams can give different outputs, then memoing should not be employed.  This warning can currently be disabled by setting \$IKNOWIDONTHAVEATTY."
fi

## eval caused problems when one of the args was a URL containing the '&' character
# eval "$@" > $TMPFILE
## So why were we using it?!  Because we wanted to pass it a command as a string?
## BUG: can't handle single bracket in filename eg. memo du -sk ./*
## BUG: also can't handle 's in filenames

## DONE: I also had problems with spaces I think, hence...
TOEVAL=""
for ARG in "$@"
do TOEVAL="$TOEVAL""\"$ARG\" "
done
eval "$TOEVAL" > $TMPFILE

## OK what happens without eval?
# "$@" > $TMPFILE
## Um yeah, without eval, those commands which use pipes don't work!

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
