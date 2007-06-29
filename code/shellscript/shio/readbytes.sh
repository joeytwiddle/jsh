TO_READ="$1"

# NUM_READ=` ddshowbytes bs="$TO_READ" count=1 `

while true
do

	if [ "$TO_READ" = 0 ]
	then exit 0
	fi

	jshinfo "[readbytes] requesting $TO_READ bytes"

	DDLOGFILE=/tmp/$$.ddlog
	dd bs="$TO_READ" count=1 2> "$DDLOGFILE"
	NUM_READ=` tail -n 1 "$DDLOGFILE" | sed 's+ bytes .*++' `
	rm -f "$DDLOGFILE"

	jshinfo "[readbytes] received $NUM_READ bytes"

	if [ "$NUM_READ" = 0 ]
	then exit 1
	fi

	TO_READ=$((TO_READ-NUM_READ))

	# jshinfo "[readbytes] still reading $TO_READ"

done

