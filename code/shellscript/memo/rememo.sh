#!/bin/bash
# jsh-ext-depends: sed md5sum tty realpath
# jsh-depends: memo jdeltmp jgettmpdir jgettmp realpath md5sum error jshwarn
# jsh-ext-depends-ignore: streams
# jsh-depends-ignore: cursemagenta cursenorm debug

## FEATURE ISSUE: rememo does not actually replace the old stored memo, so the
## cache is often the first output, not the last output.  Sometimes this is
## desirable (being lazy in a shell), sometimes this is not desirable (watching
## something for changes).

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

## Generating the MEMOFILE is now all in one place, in the memo script.
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
	# error "MEMOFILE was not exported to rememo"
	# error "rememo can no longer be called directly; please use \"memo -c true\" instead."
	# exit 1
	## FIXED BUG: doh, why don't we just do that here?!
	[ "$DEBUG" ] && debug "rememo: Calling memo -c true $*"
	memo -c true "$@"
	## This is still getting called, so it's still needed!
	## Plenty of scripts (and users) use 'rememo' instead of 'memo -c true'.
	## TODO CONSIDER export REMEMO=true ; memo ...
	exit
fi
mkdir -p `dirname "$MEMOFILE"`

# [ "$DEBUG" ] && debug "REMEMO:   `cursemagenta`$NICECOM`cursenorm`"
[ "$DEBUG" ] && debug "rememo: \"$*\" > \"$MEMOFILE\""

TMPFILE=`jgettmp tmprememo`

## Is stdin being piped?  If so, memo may not be doing what the user thought!  Warn them...
if [ ! "$IKNOWIDONTHAVEATTY" ] && ! tty -s
then jshwarn "\"rememo $*\" found no tty (`tty`).  If different input streams can give different outputs, then memoing should not be employed.  This warning can currently be disabled by setting \$IKNOWIDONTHAVEATTY."
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
# CMD="$1" ; shift
# declare -a TOEVAL
# TOEVAL=""
# for ARG in "$@"
# do
	# ARG=$(echo "$ARG" | sed 's+`+\\`+g')
	# TOEVAL=( ${TOEVAL[@]} "$ARG" )
# done
# # eval "$TOEVAL" > $TMPFILE
# # EXITWAS="$?"

# eval "$TOEVAL" | tee $TMPFILE ## no need to wait before catting; better for streaming :) , although tee seems to buffer at 4k, but only when |ed :/
## DONE: tee loses the exit code, but if we could send that as a separate message (eg. via a file, or using exec), we could use tee :)
## DONE: ok we could solve this eg. by making the last line of stderr contain the exit code...?
(
	## NOTE: It falsely thought it had completed one time (before I added jdeltmp)
	##       Philosophy now is that $TMPFILE.exitcode will be empty if the eval is interrupted and the (..) breaks out.
	jdeltmp $TMPFILE.exitcode
	## FIXED BUG: We can get problems with expansion, e.g. the argument "`|Hybrid|`"
	"$@"   ## Why wasn't this the default?
	# # eval "${TOEVAL[@]}"
	# "$CMD" "${TOEVAL[@]}"   ## This was the default (with the CMD="$1" paragraph above also uncommented)
	# # eval "$@"
	echo "$?" > $TMPFILE.exitcode
) | tee $TMPFILE
## TODO: can we prevent tee's 4k buffering when stdout is not direct to terminal?  (eg. if stdout is |ed to highlight)
EXITWAS=`cat $TMPFILE.exitcode`
#echo "[rememo] EXITWAS: $EXITWAS" >&2

## At the moment, only successful executions are actually memo-ed.
if [ "$EXITWAS" = 0 ] || [ ! -z "$MEMO_IGNORE_EXITCODE" ]
then
	mv -f $TMPFILE "$MEMOFILE"
	# cat "$MEMOFILE" ## not needed now teeing
else
  [ "$DEBUG" ] && debug "rememo: not caching since command gave exit code $EXITWAS: $*"
	# cat $TMPFILE ## not needed now teeing
fi

jdeltmp $TMPFILE $TMPFILE.exitcode

## We can't use exit "$EXITWAS" or return "$EXITWAS" if we want to use this
## script as a function and/or a normal script, so we do:
[ -z "$EXITWAS" ] || [ "$EXITWAS" = 0 ]
## But we would really prefer to "set" the correct exit code.  (We could make a
## function that uses return to achieve that.)

