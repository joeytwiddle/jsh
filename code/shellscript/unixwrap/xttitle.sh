#!/bin/sh

## TODO: for the sake of X and X watchers, should strip at, say 80 chars; I saw fluxbox and gnome-tasklisk-app go mad.  Also, should do this for all character-coded title commands to the xterm in jsh

## We do not check if xisrunning, because it can still work through ssh, even if X cannot be detected.
## We do not check if we are connected to a tty, because sometimes we want to set the title even if we aren't!  e.g. tarcfzwithprogress with the TO_XTTITLE option enabled.

## Since xttitle presumably has its own heuristics, it might make sense to use our own heuristics only when using our fallback.
## But an advantage with keeping them here is for testing purposes: if we miss valid terminals out of this list, this script will fail regardless of whether xttitle is present or not.
## Another advantage is that jwhich is slow, so this order has better performance in case of rejection.
[ "$TERM" = xterm ] || [ "$TERM" = "xterm-256color" ] || [ "$TERM" = Eterm ] || exit 0

# [ "$DEBUG" ] && debug "TERM=$TERM tty=`tty` so running xttitle $*"

display_str="$XTTITLE_PRESTRING""$*"

## Runs the official xttitle if it is present, otherwise runs our own fallback.
if jwhich xttitle > /dev/null 2>&1
then unj xttitle "$display_str"
else
	# printf "]0;""$display_str"""
	# echo -n "]0;""$display_str"""
	# echo "]0;""$display_str""" | tr -d "\n"
	## These arguments to echo are not available with /bin/sh shebang
	# echo -ne "\033]0;${display_str}\007" | tr '\n' '\\' >&2
	## Previously I was doing >/dev/stderr here, but that failed after `su - [user]`
	printf "%s" "]0;""$display_str""" | tr '\n' '\\' >&2
	## Note the version in xttitleprompt is a bit different:
	# export XTTITLEBAR="\[\033]0;$TITLEBAR\007\]"
fi

