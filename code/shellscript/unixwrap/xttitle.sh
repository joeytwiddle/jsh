#!/bin/sh

## FAILED EXPERIMENT:
# tty -s || exit 0 ## not in a terminal, let alone an xterm :P
# [ "$TTY" ] || exit 0 ## not in a terminal, let alone an xterm :P
## THIS DOES NICELY DETECT when we are not directly in user shell.
## But it's a problem if subscript wants to do something, e.g.
## tarcfzwithprogress was dropping out here.

## EXPERIMENT 2:
[ "$TERM" ] || exit 0
## EXPERIMENT 3:
[ "$TERM" = xterm ] || exit 0
## EXPERIMENT 4:
# [ "$TERM" = screen ] && exit 0
## In my Linux console, TERM=linux
## Abort if no X display:
[ "$DISPLAY" ] || exit 0

[ "$DEBUG" ] && debug "TERM=$TERM tty=`tty` so running xttitle $*"

# . term_state > /dev/null 2>&1

## TODO: for the sake of X and X watchers, should strip at, say 80 chars; I saw fluxbox and gnome-tasklisk-app go mad.  Also, should do this for all character-coded title commands to the xterm in jsh
## Note formatting: % must be %%, ...
# ## Only runs the official xttitle if it is present
# ## Under Unix I had to put 2>&1 last.
DISPLAY_STR="$XTTITLE_PRESTRING""$*"
if jwhich xttitle > /dev/null 2>&1
then unj xttitle "$DISPLAY_STR"
else
	## printf has problems with the % in:
	##   grep "#dpkg-buildpackage" debuild.out | after "\% "
	## solved by using %s of course!
	## This script now DIY sends the special chars itself
	## ah but that doesn't work remotely, better to run official xttitle!
	## But now needs:
	# if xisrunning
	if [ "$TERM" = xterm ]
	then
		# printf "]0;""$DISPLAY_STR"""
		# echo -n "]0;""$DISPLAY_STR"""
		# echo "]0;""$DISPLAY_STR""" | tr -d "\n"
		printf "%s" "]0;""$DISPLAY_STR""" | tr '\n' '\\' > /dev/stderr
		## Note the version in xttitleprompt is a bit different:
		# export XTTITLEBAR="\[\033]0;$TITLEBAR\007\]"
	fi
fi


