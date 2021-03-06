#!/bin/sh
SLEEPTIME=5

INTERFACE="$1"
[ -z "$INTERFACE" ] && INTERFACE=`ifonline`

while true
do

	/sbin/tc -s qdisc ls dev "$INTERFACE" |
	grep "^[ ]*Sent " |
	numbereachline

	sleep "$SLEEPTIME"

done |

while read NUM dummy NUMBYTES dummy NUMPKTS dummy
do
	VARNAME="COUNT$NUM"
	eval "COUNT=$""$VARNAME"
	if [ "$COUNT" ]
	then
		DIFF=`expr "(" "$NUMBYTES" - "$COUNT" ")" / "$SLEEPTIME"`
		[ "$NUM" = 000 ] && clear
		# echo "$NUM	$NUMBYTES	+ $DIFF"
		printf "%s  % 12d  + % 9d\n" "$NUM" "$NUMBYTES" "$DIFF"
	fi
	COUNT="$NUMBYTES"
	eval "$VARNAME=$COUNT"
done
