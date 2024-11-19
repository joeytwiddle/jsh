#!/bin/sh

## Displays man page AND/OR jsh documentation for given command.

JMAN_SPECIAL_COLORS=1
## But don't try to do that if xrdb is not present
if ! command -v xrdb >/dev/null 2>&1
then JMAN_SPECIAL_COLORS=''
fi

## Popup the man window first if running in X:
if xisrunning
then
	## echo -e failed to output the \n correctly in sh/dash, so using printf.
	## Needed to add "VT100." for them to work in Ubuntu.
	## TODO: rxvt users will need: URxvt.colorIT: #87af5f URxvt.colorBD: #d7d7d7 URxvt.colorUL: #87afd7
	## TODO: Why not move this inside manpopup?
	[ -n "$JMAN_SPECIAL_COLORS" ] && printf "*VT100.colorBDMode: on\n*VT100.colorULMode: on\n*VT100.colorBD: blue\n*VT100.colorUL: brown" | xrdb -merge
	manpopup "$@"
	[ -n "$JMAN_SPECIAL_COLORS" ] && ( sleep 5 ; printf "*VT100.colorBDMode: off\n*VT100.colorULMode: off" | xrdb -merge ) &
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
