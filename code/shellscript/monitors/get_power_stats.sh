#!/bin/sh

# Show battery state. With "-mini", a compact form suitable for a tmux
# status bar, e.g. "87%\2h34m" (discharging), "87%/0h12m" (charging),
# "Charged" (plugged in and full), or "3%_?" (critically low).
# Without "-mini", a verbose "percentage state time_to_end" line.
#
# On Linux: uses upower.
# On macOS: parses pmset -g batt.

case "$(uname)" in
	Darwin)
		info=$(pmset -g batt 2>/dev/null | grep -E 'InternalBattery|Battery-')
		[ -z "$info" ] && exit 0

		percentage=$(printf '%s\n' "$info" | sed -n 's/.*[[:space:]]\([0-9][0-9]*\)%.*/\1/p')
		raw_state=$(printf '%s\n' "$info" | sed -n 's/.*%; *\([^;]*\);.*/\1/p')
		time_str=$(printf '%s\n' "$info" | sed -n 's/.*; *\([0-9][0-9]*:[0-9][0-9]\) remaining.*/\1/p')

		# Normalise state to match the Linux vocabulary used below.
		case "$raw_state" in
			discharging)                 state=discharging ;;
			charging)                    state=charging ;;
			charged|'AC attached'|'finishing charge')
										 state=fully-charged ;;
			*)                           state="$raw_state" ;;
		esac

		if [ "$1" = -mini ]
		then
			mini_state='?'
			if [ "$state" = discharging ]
			then mini_state='\\'
			elif [ "$state" = charging ]
			then mini_state='/'
			elif [ "$state" = fully-charged ]
			then
				echo "Charged"
				exit 0
			fi

			if [ -n "$time_str" ]
			then
				h=$(echo "$time_str" | cut -d: -f1)
				m=$(echo "$time_str" | cut -d: -f2)
				mini_time="${h}h${m}m"
			else mini_time='?'
			fi

			if [ -n "$percentage" ] && [ "$percentage" -lt 7 ] && [ "$state" != charging ]
			then mini_state='_'
			fi

			echo "${percentage}%${mini_state}${mini_time}"
		else echo "$percentage $state $time_str"
		fi
		;;
	*)
		# Original Linux implementation.
		battery_id=$(upower -e 2>/dev/null | grep battery | tail -n 1)
		stats=$(upower -i "$battery_id" 2>/dev/null)

		getvalue() {
			printf "%s\n" "$stats" | grep "^ *$1:" | sed 's+[^:]*: *++'
		}

		state=$(getvalue "state")
		time_to_end=$(getvalue "time to \(full\|empty\)")
		[ -z "$time_to_end" ] && time_to_end='?'
		percentage=$(getvalue "percentage")

		if [ "$1" = -mini ]
		then
			mini_state='?'
			if [ "$state" = "discharging" ]
			then mini_state='\\'
			elif [ "$state" = "charging" ]
			then mini_state='/'
			elif [ "$state" = "fully-charged" ]
			then
				echo "Charged"
				exit 0
			fi

			mini_time=$(echo "$time_to_end" | sed 's+\.[0-9]*++ ; s+ hours+h+ ; s+ minutes+m+ ; s+ seconds+s+')
			mini_percentage=$(echo "$percentage" | sed 's+[.%].*++')

			if [ -n "$mini_percentage" ] && [ "$mini_percentage" -lt 7 ] && [ ! "$state" = "charging" ]
			then mini_state='_'
			fi

			echo "${mini_percentage}%${mini_state}${mini_time}"
		else echo "$percentage $state $time_to_end"
		fi
		;;
esac
