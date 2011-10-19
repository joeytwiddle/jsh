#!/bin/sh
# jsh-depends: unj screentitle
## screen (this script) with no args should only be interactive when run
## by user directly from shell, so make interactivity an option, and make
## an alias for it.

# export SCREEN_RUNNING=true (so how do we know?)
## To prioritise screen over X window management
## Kinda inconvenient though: would be nice if user could prioritise screen at will and still be able to exec X apps
export DISPLAY=

## This _might_ get it to buggy if problems persist:
# # export WINNAMEW
# export STY
## But now disabled because of manpopup problems.  Why would we want it?

## Actually you are not recommended to export SCREEN_COMMAND_CHARS,
## unless you are happy for them to be applied to new/resumed child screens too.
[ "$SCREEN_COMMAND_CHARS" ] || SCREEN_COMMAND_CHARS="^k^l"
# DEFAULT_SCREEN_OPTIONS="-h 10000 -a -e$SCREEN_COMMAND_CHARS"
DEFAULT_SCREEN_OPTIONS="-h 1200 -a -e$SCREEN_COMMAND_CHARS"
unset SCREEN_COMMAND_CHARS

if test "$*"
then

	unj screen $DEFAULT_SCREEN_OPTIONS "$@"

else

	echo "Once attached, press Ctrl+k then ? for help."
	echo "To reach deeper screens, press Ctrl+k then Ctrl+l's."
	unj screen -list
	# sleep 1
	# DEFNAME=`hostname | beforefirst "\."`
	DEFNAME="$SHORTHOST"
	[ "$DEFNAME" ] || DEFNAME="$HOST"
	echo "Type session name to attach or start new (<Enter> defaults to \"$DEFNAME\")."
	read NAME
	test "$NAME" || NAME="$DEFNAME"
	test "$NAME" || NAME=screen
	export SCREENNAME="$NAME"
	screentitle -remote "[$SHORTHOST:$SCREENNAME]"
	screen $DEFAULT_SCREEN_OPTIONS -S "$NAME" -D -RR
	## Multi-session, but fails if doesn't exist :-(
	# screen -h 1200 -a "-e^k^l" -S "$NAME" -x

fi
