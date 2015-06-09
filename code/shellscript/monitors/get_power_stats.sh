battery_id=`upower -e | grep battery | tail -n 1`
stats=`upower -i "$battery_id"`

getvalue() {
	printf "%s\n" "$stats" |
	grep "^ *$1:" | sed 's+[^:]*: *++'
}

state=`getvalue "state"`
time_to_end=`getvalue "time to \(full\|empty\)"`
percentage=`getvalue "percentage"`

if [ "$1" = -mini ]
then

	# Tiny summary suitable for e.g. tmux statusbar.

	mini_state='?'
	if [ "$state" = "discharging" ]
	then mini_state='\\'
	elif [ "$state" = "charging" ]
	then mini_state="/"
	elif [ "$state" = "fully-charged" ]
	then mini_state="f"
		echo "Charged"
		exit
	fi

	mini_time=`echo "$time_to_end" | sed 's+ hours+h+ ; s+ minutes+m+ ; s+ seconds+s+'`
	mini_percentage=`echo "$percentage" | sed 's+\..*++'`"%"

	echo "$mini_percentage$mini_state$mini_time"

else

	echo "$percentage $state $time_to_end"

fi
