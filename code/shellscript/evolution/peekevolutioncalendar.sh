for DAYSAHEAD in `seq -7 30`; do
	DATESTR="today + $DAYSAHEAD days"
	UNIV=`date -d "$DATESTR" -I | tr -d "-"`
	NICEDATE=`date -d "$DATESTR" "+%A %e %B" | tr -s " "`
	if test "$DAYSAHEAD" = 0; then
		NICEDATE="$NICEDATE "`cursemagenta`"[*** TODAY ***]"`curseyellow`
	fi
	startswith "$NICEDATE" "S" &&
		cursegreen ||
		curseyellow
	echo "$NICEDATE  -----------------------"
	cursenorm
	FOUND=`grep "$UNIV" "$HOME/evolution/local/Calendar/calendar.ics"`
	if test ! "$FOUND" = ""; then
		echo "$FOUND" |
		while read X
		do
			echo
			echo "$X"
			cat "$HOME/evolution/local/Calendar/calendar.ics" |
			fromstring "$X" |
			tostring "END:VEVENT"
		done
	fi
	echo
done
