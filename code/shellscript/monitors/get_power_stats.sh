#!/bin/sh

battery_id=`upower -e 2>/dev/null | grep battery | tail -n 1`
stats=`upower -i "$battery_id" 2>/dev/null`

getvalue() {
	printf "%s\n" "$stats" |
	grep "^ *$1:" | sed 's+[^:]*: *++'
}

state=`getvalue "state"`
time_to_end=`getvalue "time to \(full\|empty\)"`
# Sometimes there just isn't a time value.
[ -z "$time_to_end" ] && time_to_end="?"
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

	mini_time=`echo "$time_to_end" | sed 's+\.[0-9]*++ ; s+ hours+h+ ; s+ minutes+m+ ; s+ seconds+s+'`
	mini_percentage=`echo "$percentage" | sed 's+[.%].*++'`

	if [ -n "$mini_percentage" ] && [ "$mini_percentage" -lt 7 ] && [ ! "$state" = "charging" ]
	then
		mini_state="_"
		#mini_time="!!!"
	fi

	echo "${mini_percentage}%${mini_state}${mini_time}"

else

	echo "$percentage $state $time_to_end"

fi
