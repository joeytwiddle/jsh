## A simple visualisation for tc traffic
## Show bars representing the amount of traffic passed through each class, and highlights the changes.

SEDSTR=`
cat << ! |
11 games
12 tos
13 mail
14 int
15 ssh
16 other
17 small
18 websrv
19 big
!

while read NUM TYPE
do echo -n "s+$NUM:+$NUM$TYPE:+g;"
done | beforelast ";"
`

INTERFACE=`ifonline`

# jwatchchanges -fine /sbin/tc -s qdisc ls dev $INTERFACE "|" trimempty "|" sed "\"$SEDSTR\"" | highlight '[^ ]*:'

add_levels_to_tc_output () {
	TMPFILE=/tmp/tc_output.tmp
	/sbin/tc -s qdisc ls dev $INTERFACE | trimempty | sed "$SEDSTR" > "$TMPFILE"
	TOTAL=`cat "$TMPFILE" | grep "^ *Sent " | tail -n 1 | beforefirst " bytes " | afterlast " "`
	cat "$TMPFILE" |
	while read ARG1 ARG2 REST
	do
		if [ "$ARG1" = Sent ]
		then
			# jshinfo "$ARG2 / $TOTAL"
			PROP="$(((COLUMNS-4)*ARG2/TOTAL))"
			BAR=""
			for X in `seq 0 $PROP`
			do BAR="$BAR""#"
			done
			echo " Sent $ARG2 $REST"
			echo "[$BAR]"
		else
			if [ "$ARG1" = qdisc ]
			then echo
			fi
			echo "$ARG1 $ARG2 $REST"
		fi
	done
}

add_levels_to_tc_output

. importshfn jwatchchanges

jwatchchanges -fine add_levels_to_tc_output | highlight '[^ ]*:'

