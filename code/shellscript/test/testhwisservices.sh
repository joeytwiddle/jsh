function checkWebPageForRegexp () {
	echo "`curseyellow`Checking URL $1 for string \"$2\" ...`cursenorm`"
	OUTPUT=`
		wget -nv -O - "$1" & wgpid=$!
		sleep 5 ; kill $wgpid 2>/dev/null
	`
	if echo "$OUTPUT" | grep "$2" > /dev/null
	then
		echo "`cursegreen;cursebold`OK: Found \"$2\" in \"$1\" ok.`cursenorm`"
	else
		echo "`cursered;cursebold`FAILED to find \"$2\" in \"$1\"!`cursenorm`" >&2
		FAILED=true
	fi
}

function askPortExpect () {
	echo "`curseyellow`Connecting to $1:$2 sending \"$3\" hoping to get \"$4\" ...`cursenorm`"
	RESPONSE=`
		( echo "$3" ; sleep 99 ) |
		nc "$1" "$2" & ncpid=$!
		sleep 5 ; kill $ncpid 2>/dev/null
	`
	if echo "$RESPONSE" | grep "$4"
	then
		echo "`cursegreen;cursebold`OK: Got response containing \"$4\" from $1:$2.`cursenorm`"
	else
		echo "`cursered;cursebold`FAILED to get \"$4\" from $1:$2!`cursenorm`" >&2
		FAILED=true
	fi
}

FAILED=false

askPortExpect hwi.ath.cx 25 "HELO" "SMTP"

echo

checkWebPageForRegexp "http://hwi.ath.cx/" "How to contact Joey"

echo

checkWebPageForRegexp "http://emailforever.net/cgi-bin/openwebmail/openwebmail.pl" "Open"

echo

checkWebPageForRegexp "http://generation-online.org/" "Generation"

[ "$FAILED" = false ] || exit 99
