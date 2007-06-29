## Sometimes (e.g. when using datediff to determine slowest processes from a log) it's preferable
## to diaply the time taken beside (or at the end of) the last line, rather than the line reached.
## TODO: make an option for this

LAST_LINE_SECONDS=

"$@" | dateeachline -fine |
sed 's+^\[\([^.]*\)\.[^]]*\]+\1+' | ## extract just seconds as first field
# sed 's+^\[\([^.]*\)\.\([^]]*\)\]+\1\2+' | ## seconds and nanos

while read SECONDS LINE
do

	if [ ! "$LAST_LINE_SECONDS" ]
	then
		echo "...	$LINE"
	else
		SECONDS_SINCE_LAST_LINE=$((SECONDS-LAST_LINE_SECONDS))
		echo "$SECONDS_SINCE_LAST_LINE	$LINE"
	fi

	LAST_LINE_SECONDS="$SECONDS"

done
