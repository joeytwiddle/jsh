## No shebang.  I should be sourced from bash (or perhaps zsh) but not POSIX sh (fails with dash - the args are not passed when sourcing).
## To use selfmemo, make the following the first command in your script:
# . selfmemo [ -nodir ] [ <memo_opts>... ] - "$0" "$@"; shift
## Note: there appears to be a BUG, you cao do -t 20 but -t "1 minute" doesn't work.  Hmm -t 20 doesn't work for me either
## Also NOTE: do NOT use -nodir because it changes the current shell's current directory.

## CONSIDER: Can't this script, since it is sourced, work out "$0" and "$@" itself?
##           But that would require that we pass no opts, which means we cannot pass memo_opts.

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
	[ "$DEBUG" ] && debug "selfmemo: `cursemagenta`$COMMAND $*`cursenorm`"
	memo $MEMO_OPTS "$COMMAND" -self-memoing-ok "$@"
	## Important, now that we have effectively performed the command, exit the caller to prevent calling it again!
	exit

fi
