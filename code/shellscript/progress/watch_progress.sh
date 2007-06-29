## watch_progress <expected_max> <command_returning_current>...

MAX="$1"
shift
COMMAND="$*"

while true
do

	CURRENT=`"$@"`
	PROPORTION=$((100*CURRENT/MAX))

	echo -e -n "\r$CURRENT/$MAX = $PROPORTION% "

	[ "$PROPORTION" -gt 99 ] && break

	sleep 5

done

echo
