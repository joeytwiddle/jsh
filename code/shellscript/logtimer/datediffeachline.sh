#!/bin/sh

## Sometimes (e.g. when using datediff to determine slowest processes from a log) it's preferable
## to diaply the time taken beside (or at the end of) the last line, rather than the line reached.
## TODO: make an option for this

LAST_LINE_SECONDS=

export FORMAT="%s%N"

if [ -n "$*" ]
then "$@"
else cat
fi |

# dateeachline -fine |
# sed 's+^\[\([^.]*\)\.[^]]*\]+\1+' | ## extract just seconds as first field
# sed 's+^\[\([^.]*\)\.\([^]]*\)\]+\1\2+' | ## seconds and nanos

# while read SECONDS LINE
while read LINE
do

	if [ -n "$LAST_LINE_SECONDS" ]
	then
		SECONDS=`date +"$FORMAT"`
		SECONDS_SINCE_LAST_LINE=$((50*(SECONDS-LAST_LINE_SECONDS)/100000000))
		# echo "$SECONDS_SINCE_LAST_LINE	$LAST_LINE"
		# DOTS="" ; for I in `seq 1 $SECONDS_SINCE_LAST_LINE`; do DOTS="$DOTS""."; done
		DOTS="`yes . | head -n "$SECONDS_SINCE_LAST_LINE" | tr -d '\n'`"
		echo "$DOTS"
	else
		echo "...	$LINE"
	fi

	echo -n "$LINE"

	LAST_LINE_SECONDS=`date +"$FORMAT"`
	LAST_LINE="$LINE"

done

echo "$DOTS?"
