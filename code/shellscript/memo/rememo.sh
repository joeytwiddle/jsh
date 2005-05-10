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

## DONE: Instead of repeating the code for the checksum here, why doesn't memo pass it in, and rememo can barf otherwise?  (External uses of/dependencies on rememo?  See "jdoc rememo"...DONE :)

# [ "$DEBUG" ] && debug "REMEMO:   `cursemagenta`$*`cursenorm`"

### NOTE: These next two blocks were direct copies from memo:

# . jgettmpdir -top
# MEMODIR=$TOPTMP/memo

# if [ "$MEMO_IGNORE_DIR" ] || [ "$PWD" = / ]
# then REALPWD="/"
# else REALPWD=`realpath "$PWD"`
# fi
# CKSUM=`echo "$REALPWD/$*" | md5sum`
# if [ "$DEBUG_MEMO" ]
# then NICECOM=`echo "$CKSUM..$*..$REALPWD" | tr " \n/" "__+" | sed 's+\(................................................................................\).*+\1+'`
# else NICECOM="$CKSUM"
# fi
# MEMOFILE="$MEMODIR/$NICECOM.memo"
# mkdir -p "$MEMODIR"

## NOTE: But now we just check the one neccessary var has been provided :)

if [ ! "$MEMOFILE" ]
then
	error "MEMOFILE was not exported to rememo"
	error "rememo can no longer be called directly; please use \"memo -c true\" instead."
	exit 1
fi
mkdir -p `dirname "$MEMOFILE"`

[ "$DEBUG" ] && debug "REMEMO:   `cursemagenta`$NICECOM`cursenorm`"

TMPFILE=`jgettmp tmprememo`

if ! tty >/dev/null && [ ! "$IKNOWIDONTHAVEATTY" ]
then jshwarn "rememo found no pts on \"$*\".  If different input streams can give different outputs, then memoing should not be employed.  This warning can currently be disabled by setting \$IKNOWIDONTHAVEATTY."
fi

## This doesn't work if input is "x | y"
# "$@" | tee "$MEMOFILE"
## Yeah, and also | tee means we lose the exit code :/

## OK what happens without eval?
# "$@" > $TMPFILE
## Um yeah, without eval, those commands which use pipes don't work!
## AHA!  But _that_ can be achieved by passing eval is an the first parameter of "$@".
## SO TODO: we should switch back to this method, and then add eval to all script which need it.  Or is that too nasty?  Should we give them their |s automatically?!

## eval caused problems when one of the args was a URL containing the '&' character
# eval "$@" > $TMPFILE
## So why were we using it?!  Because we wanted to pass it a command as a string?
## BUG: can't handle single bracket in filename eg. memo du -sk ./*
## BUG: also can't handle 's in filenames

## DONE: I also had problems with spaces I think, hence yuk (" escaping??!)...
TOEVAL=""
for ARG in "$@"
do TOEVAL="$TOEVAL""\"$ARG\" "
done
eval "$TOEVAL" > $TMPFILE
# eval "$TOEVAL" | tee $TMPFILE ## no need to wait before catting; better for streaming :) , although tee seems to buffer at 4k, but only when |ed :/
## TODO: tee loses the exit code, but if we could send that as a separate message (eg. via a file, or using exec), we could use tee :)

EXITWAS="$?"
## At the moment, only successful executions are actually memo-ed.
if [ "$EXITWAS" = 0 ]
then
	mv -f $TMPFILE "$MEMOFILE"
	cat "$MEMOFILE"
else
  [ "$DEBUG" ] && debug "rememo: not caching since command gave exit code $EXITWAS: $*"
	cat $TMPFILE
fi
jdeltmp $TMPFILE

## Ideal for script, but caused problems when importshfn rememo was used:
# exit "$EXITWAS"
## But if imported as function:
# return "$EXITWAS"
## So compromise:
[ ! "$EXITWAS" ] || [ "$EXITWAS" = 0 ]
