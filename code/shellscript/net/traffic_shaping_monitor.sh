#!/bin/zsh

# jsh-depends: jwatchchanges trimempty beforefirst beforelast importshfn ifonline highlight afterlast jshinfo
# jsh-ext-depends-ignore: ssh

## A simple visualisation for tc traffic
## Show bars representing the amount of traffic passed through each class, and highlights live changes.

## zsh is needed to perform the real arithmetic to calculate DATEDIFF
dateFormat="%s.%N"
if [ -z "$ZSH_NAME" ]
then
	echo "Warning: traffic_shaping_monitor should be run in zsh (for accurate timing arithmetic)!"
	# exit 3
	dateFormat="%s"
fi

OLDSEDTABLE="
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
10: high
20: normal
30: low
"

SEDTABLE="
10: high
20: normal
30: low
2:1 HIGH
2:2 NORMAL
2:3 LOW
"

SEDSTR=`
echo "$SEDTABLE" | grep -v '^$' |
while read NUM TYPE
do echo -n "s+$NUM+$NUM~$TYPE+g;"
done | beforelast ";"
`

INTERFACE="$1"
[ -n "$INTERFACE" ] || INTERFACE=`ifonline`

# jwatchchanges -fine /sbin/tc -s qdisc ls dev $INTERFACE "|" trimempty "|" sed "\"$SEDSTR\"" | highlight '[^ ]*:'

TMPFILE=/tmp/tc_output.$USER.$$
add_levels_to_tc_output () {
	/sbin/tc -s qdisc ls dev $INTERFACE | trimempty | sed "$SEDSTR" > "$TMPFILE"
	## The first "Sent" number in the file should be the #bytes sent in the root class, i.e. the total bytes sent.
	TOTAL=`cat "$TMPFILE" | grep "^ *Sent " | head -n 1 | beforefirst " bytes " | afterlast " "`
	# [ "$LAST_TOTAL" ] && echo "$TOTAL - $LAST_TOTAL = $((TOTAL-LAST_TOTAL))"
	TIME=$(date +$dateFormat)
	while read ARG1 ARG2 ARG3 REST
	do
		# lastSentRef="last_sent_$CURDISC"
		# newSentRef="new_sent_$CURDISC"
		if [ "$ARG1" = Sent ]
		then
			## -13 to make space for $DIFF
			PROP="$(((COLUMNS-4-13)*ARG2/TOTAL))"
			[ "$CURDISC" = "" ] && CURDISC="999"
			# jshinfo "$CURDISC: $ARG2 / $TOTAL"
			new_sent[$CURDISC]="$ARG2"
			if [ "$CURDISC" = 999 ]
			then
				BAR="unknown_class"
			else
				BAR=""
				for X in `seq 0 $PROP`
				do BAR="$BAR""#"
				done
			fi
			echo "Sent $ARG2 $ARG3 $REST"
			echo -n "[$BAR]"
			if [ "${new_sent[$CURDISC]}" ] && [ "${last_sent[$CURDISC]}" ]
			then
				DATEDIFF=$((TIME-LAST_TIME))
				[ -z "$ZSH_NAME" ] && jshinfo "DATEDIFF= $TIME - $LAST_TIME = $DATEDIFF"
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
			then CURDISC=`echo "$ARG3" | sed 's+[^0-9]*++g'` ; echo
			fi
			echo "$ARG1 $ARG2 $ARG3 $REST"
		fi
	done < "$TMPFILE"
	rm -f "$TMPFILE"
	# last_sent=${new_sent}
	LAST_TOTAL="$TOTAL"
	LAST_TIME="$TIME"
}

add_levels_to_tc_output
[ -z "$ZSH_NAME" ] && sleep 2

. importshfn jwatchchanges

jwatchchanges -fine -n 5 add_levels_to_tc_output | highlight -bold '[^ ]*:[^ ]*~[^ ]*' blue

