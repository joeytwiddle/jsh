## NOTE: When joeysaliases aliased tail=prettytail, it caused sourced scripts from user shell problems: eg. b.zsh used tail (->prettytail) but now uses 'tail'

## TODO: make it not repeat until file gets updated, then isn't changed for $SLEEPTIME seconds.
## TODO: make it turn off-onable from jsh config

(
	# SLEEPTIME=5
	SLEEPTIME=15
	while true
	do
		sleep $SLEEPTIME
		# echo >&2
		echo "[tail] ... $SLEEPTIME seconds passed" | highlight ".*" >&2
		# echo >&2
	done
) &
PID="$!"

unj tail "$@"

kill "$PID"
