## TODO: make it not repeat until file gets updated, then isn't changed for $SLEEPTIME seconds.
## TODO: make it turn off-onable from jsh config

(
	# SLEEPTIME=5
	SLEEPTIME=15
	while true
	do
		sleep $SLEEPTIME
		echo >&2
		echo "[tail] ... $SLEEPTIME seconds passed" >&2
		echo >&2
	done
) &
PID="$!"

unj tail "$@"

kill "$PID"
