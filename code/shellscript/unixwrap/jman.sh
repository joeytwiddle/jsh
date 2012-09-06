#!/bin/sh
JMAN_SPECIAL_COLORS=1

## Popup the man window first if running in X:
if xisrunning
then
	## echo -e failed to output the \n correctly in sh/dash, so using printf.
	[ -n "$JMAN_SPECIAL_COLORS" ] && printf "*colorBDMode: on\n*colorULMode: on\n*colorBD: blue\n*colorUL: brown" | xrdb -merge
	manpopup "$@"
	[ -n "$JMAN_SPECIAL_COLORS" ] && ( sleep 5 ; printf "*colorBDMode: off\n*colorULMode: off" | xrdb -merge ) &
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
