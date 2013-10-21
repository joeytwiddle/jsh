#!/bin/sh

## These days we have |datediffeachline .  I strongly recommend using that over prettytail!  Perhaps it should replace this.  Done!  It is not quite as pretty though.

tail "$@" | datediffeachline
exit



## NOTE: When joeysaliases aliased tail=prettytail, it caused sourced scripts from user shell problems: eg. b.zsh used tail (->prettytail) but now uses 'tail'
## BUG TODO: The sleep reporter backgrounds itself when run from the cmdline, and when user Ctrl-Cs the main tail, the sleep reporter continues!

## TODO: make it not repeat until file gets updated, then isn't changed for $SLEEPTIME seconds.
## TODO: make it turn off-onable from jsh config

## TODO: Those arguments which are files could be sorted according to their last-modified time, so that prettytail -5f will show the latest log lines last.

## Only run prettytail if we are in a user-operated terminal, not if we are piping to somewhere (I *think* tty checks on stdout (not in), right?!).  WRONG!  See locate.
if ! tty -s
then
	unj tail "$@"
	exit
fi

## We don't really need this option.  Since the user can already |dateeachline, why offer them -dateeachline?
[ "$1" = -date ] && DATE_EACH_LINE=true && shift

(
	# SLEEPTIME=5
	SLEEPTIME=15
	while true
	do
		sleep $SLEEPTIME
		# echo >&2
		echo "[tail] ... $SLEEPTIME seconds passed" | highlight ".*" blue >&2
		# echo >&2
	done
) &
PID="$!"

# unj tail "$@" | highlight "^/usr/bin/tail: .* file truncated$" red | highlight "^==> .* <==$" yellow
highlightstderr unj tail "$@" | highlight "^==> .* <==$" yellow |

if [ "$DATE_EACH_LINE" ]
then dateeachline
else cat
fi

kill "$PID"
