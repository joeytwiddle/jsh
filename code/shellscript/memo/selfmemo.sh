## To use selfmemo, make the following the first command in your script:
# . selfmemo [ -nodir ] [ <memo_opts>... ] - "$0" "$@"; shift

if [ "$1" = -nodir ]
then cd /; shift
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

	# # echo "`cursered;cursebold`selfmemo: failed to find -self-memoing-ok in \"$1\"`cursenorm`" >&2
	# echo "`cursered;cursebold`selfmemo: memoing with: memo $MEMO_OPTS \"$COMMAND\" -self-memoing-ok \"$*\"`cursenorm`" >&2
	[ "$DEBUG" ] && debug "selfmemo: `cursemagenta;cursebold`memo $MEMO_OPTS \"$COMMAND\" -self-memoing-ok \"$*\"`cursenorm`"
	memo $MEMO_OPTS "$COMMAND" -self-memoing-ok "$@"
	## Important, now that we have effectively performed the command, exit the caller to prevent calling it again!
	exit

fi
