## See also: uniq -c, and grep -c

LASTLINE="this_string_never_gets_matched.234230984"

COUNT=0

sort |

while true
do
	
	if read LINE
	then
		# jshinfo "[$COUNT] $LINE --- $LASTLINE"
		if [ "$LINE" = "$LASTLINE" ]
		then
			COUNT=$((COUNT+1))
		else
			[ "$COUNT" -gt 0 ] && echo "$COUNT: $LASTLINE"
			# [ "$COUNT" -gt 0 ] && jshinfo "$COUNT: $LASTLINE"
			COUNT=1
		fi
		LASTLINE="$LINE"
	else
		echo "$COUNT: $LASTLINE"
		break
	fi

done

