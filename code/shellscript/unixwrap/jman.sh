## Popup the man window first if running in X:
if xisrunning
then manpopup "$@"
fi

## If the command is a jsh script, show jsh documentation (may popup, but always asks questions in the terminal):
## TODO: should always popup if called as man (in sync with real man pages!)
if [ -x "$JPATH/tools/$1" ]
then jdoc "$@"
fi

## Show the man page last if not running in X:
if ! xisrunning
then manpopup "$@"
fi
