#!/bin/zsh

## A simple visualisation for tc traffic
## Show bars representing the amount of traffic passed through each class, and highlights live changes.

## zsh is needed to perform the real arithmetic to calculate DATEDIFF

SEDSTR=`
cat << ! |
11: games
12: tos
13: mail
14: int
15: ssh
16: other
17: small
18: websrv
19: big
2:2 Ack
2:3 Int
2:4 Web
2:5 Bulk
2:6 Other
!

while read NUM TYPE
do echo -n "s+$NUM+$NUM~$TYPE+g;"
done | beforelast ";"
`

INTERFACE=`ifonline`

# jwatchchanges -fine /sbin/tc -s qdisc ls dev $INTERFACE "|" trimempty "|" sed "\"$SEDSTR\"" | highlight '[^ ]*:'

add_levels_to_tc_output () {
	TMPFILE=/tmp/tc_output.tmp
	/sbin/tc -s qdisc ls dev $INTERFACE | trimempty | sed "$SEDSTR" > "$TMPFILE"
	## The first "Sent" number in the file should be the #bytes sent in the root class, i.e. the total bytes sent.
	TOTAL=`cat "$TMPFILE" | grep "^ *Sent " | head -n 1 | beforefirst " bytes " | afterlast " "`
	# [ "$LAST_TOTAL" ] && echo "$TOTAL - $LAST_TOTAL = $((TOTAL-LAST_TOTAL))"
	TIME=$(date +%s.%N)
	while read ARG1 ARG2 ARG3 REST
	do
		# lastSentRef="last_sent_$CURDISC"
		# newSentRef="new_sent_$CURDISC"
		if [ "$ARG1" = Sent ]
		then
			# jshinfo "$ARG2 / $TOTAL"
			## -13 to make space for $DIFF
			PROP="$(((COLUMNS-4-13)*ARG2/TOTAL))"
			new_sent[$CURDISC]="$ARG2"
			BAR=""
			for X in `seq 0 $PROP`
			do BAR="$BAR""#"
			done
			echo "Sent $ARG2 $ARG3 $REST"
			echo -n "[$BAR]"
			if [ "${new_sent[$CURDISC]}" ] && [ "${last_sent[$CURDISC]}" ]
			then
				DATEDIFF=$((TIME-LAST_TIME))
				DIFF="$(( (${new_sent[$CURDISC]}-${last_sent[$CURDISC]}) / DATEDIFF ))"
				DIFF=`echo "$DIFF" | beforelast "\."`
				echo -n " [$DIFF bps]"
			fi
			echo
			# unset "$lastSentRef"
			last_sent[$CURDISC]="${new_sent[$CURDISC]}"
			## This value gets set on the first iteration, but is never updated after that.
			## I think I solved this with < "$TMPFILE" instead of cat "$TMPFILE" |
		else
			if [ "$ARG1" = qdisc ]
			then CURDISC=`echo "$ARG3" | sed 's+:$++'` ; echo
			fi
			echo "$ARG1 $ARG2 $ARG3 $REST"
		fi
	done < "$TMPFILE"
	# last_sent=${new_sent}
	LAST_TOTAL="$TOTAL"
	LAST_TIME="$TIME"
}

add_levels_to_tc_output

. importshfn jwatchchanges

jwatchchanges -fine -n 5 add_levels_to_tc_output | highlight -bold '[^ ]*:[^ ]*~[^ ]*' blue

