if [ "$1" = -nodir ]
then cd /; shift
fi

if [ "$1" = - ]
then
  shift
  MEMO_OPTS="$1"
  shift
fi

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
  [ "$DEBUG" ] && echo "`cursemagenta;cursebold`selfmemo: memoing \"$COMMAND\" \"$*\"`cursenorm`" >&2
  memo $MEMO_OPTS "$COMMAND" -self-memoing-ok "$@"
  ## Important, now that we have effective performed the command, exit the caller to prevent calling it again!
  exit

fi
