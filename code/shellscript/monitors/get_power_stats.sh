battery_id=`upower -e | grep battery | tail -n 1`
stats=`upower -i "$battery_id"`

getvalue() {
	printf "%s\n" "$stats" |
	grep "^ *$1:" | sed 's+[^:]*: *++'
}

state=`getvalue "state"`
time_to_full=`getvalue "time to full"`
percentage=`getvalue "percentage"`

if [ "$1" = -mini ]
then

	# Tiny summary suitable for e.g. tmux statusbar.

	mini_state="\\"
	if [ "$state" = "charging" ]
	then mini_state="/"
	fi

	mini_time=`echo "$time_to_full" | sed 's+ hours+h+ ; s+ minutes+m+ ; s+ seconds+s+'`
	mini_pecentage=`echo "$percentage" | sed 's+\..*++'`"%"

	echo "$mini_pecentage$mini_state$mini_time"

fi
