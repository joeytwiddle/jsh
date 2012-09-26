# +++ DO NOT add a shebang #!/bin/bash to this script!  It is meant to be sourced. +++
## selfmemo - a shortcut for a script to automatically memo its output.  Calling selfmemo will skip running the main body of the script, if a cached output is available.
## To use selfmemo, put the following near the top of your script (before any arg shifting is done).
# . selfmemo [ -nodir ] [ <memo_opts>... ] - "$0" "$@"; shift
## Calling scripts should be running in bash (or perhaps zsh) but NOT sh (it fails with dash because the args are not passed when sourcing).
## Note: there appears to be a BUG, you cao do -t 20 but -t "1 minute" doesn't work.  Hmm -t 20 doesn't work for me either

## Also NOTE: do NOT use -nodir because it changes the current shell's current directory.  OH that is now solved.

## CONSIDER: Can't this script, since it is sourced, work out "$0" and "$@" itself?
## Hmm but we might want to pass extra memo-args, then we must pass all the args.
## In fact, as long as the caller was bash (not sh), we get the args to selfmemo in $*
## but in $0 we get the caller script, not selfmemo!  (Which is what we need.)

## BUG: Ran findjshdeps with no args (when it was using selfmemo), then interrupted it with Ctrl-C.  Ran it again, expecting memo to re-run, but instead it used partial memofile!  Argh!

[ "$DEBUG" ] && debug "selfmemo ($0) called with args: $*"

## TODO/DONE: Shouldn't -nodir be a part of memo instead of selfmemo?

## After all, the above doc would force the parent process to move, which may not be desired
## TODO/DONE: if it is needed, the cd / should be hidden/separated by using a child shell
## or we could possible go back by saving $PWD
## WARN: disabled for now
# if [ "$1" = -nodir ]
# then cd /; shift
# fi
## check with: jdoc nodir

## Instead we have this solution:
if [ "$1" = -nodir ]
then export MEMO_IGNORE_DIR=true; shift
fi

MEMO_OPTS=
while [ ! "$1" = - ] && [ "$1" ]
do
	MEMO_OPTS="$MEMO_OPTS $1"
	shift
done
shift

COMMAND="$1"
shift

if [ "$1" = -self-memoing-ok ]
then

	# echo "`cursered;cursebold`selfmemo: self-memoing-ok, returning`cursenorm`" >&2
	## Doesn't work, needs to be done by caller:
	shift

else

	# [ "$DEBUG" ] && debug "selfmemo: `cursemagenta`memo$MEMO_OPTS \"$COMMAND\" -self-memoing-ok \"$*\"`cursenorm`"
	[ "$DEBUG" ] && debug "selfmemo calling `cursemagenta`memo ... $COMMAND $*`cursenorm`"
	memo $MEMO_OPTS "$COMMAND" -self-memoing-ok "$@"
	## Important, now that we have effectively performed the command, exit the caller to prevent calling it again!
	exit

fi
