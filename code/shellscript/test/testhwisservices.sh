#### TODO TODO What about all those other address: eg. open-lists.net!
#### TODO: and what about running it as a cronjob somewhere?!?!

## Functions:

function doing () {
	echo "`cursecyan`$*`cursenorm`"
}	

function good () {
	echo "`cursegreen;cursebold`$*`cursenorm`"
}

function bad () {
	echo "`cursered;cursebold`$*`cursenorm`" >&2
	FAILED=true
}

function checkWebPageForRegexp () {
	doing "Checking URL $1 for string \"$2\" ..."
	OUTPUT=`
		wget -nv -O - "$1" & wgpid=$!
		sleep 5 ; kill $wgpid 2>/dev/null
	`
	if echo "$OUTPUT" | grep "$2" > /dev/null
	then good "`cursegreen;cursebold`OK: Found \"$2\" in \"$1\" ok.`cursenorm`"
	else bad "FAILED to find \"$2\" in \"$1\"!"
	fi
}

function askPortExpect () {
	doing "Connecting to $1:$2 sending \"$3\" hoping to get \"$4\" ..."
	# NC=`which nc 2>/dev/null`
	NC=/usr/bin/nc
	[ ! -x "$NC" ] && echo "No netcat: using telnet" && NC=`which telnet`
	RESPONSE=`
		( echo "$3" ; sleep 99 ) |
		"$NC" "$1" "$2" & ncpid=$!
		sleep 5 ; kill $ncpid 2>/dev/null
	`
	if echo "$RESPONSE" | grep "$4"
	then good "OK: Got response containing \"$4\" from $1:$2."
	else bad "FAILED to get \"$4\" from $1:$2!" >&2
	fi
}



## Perform tests:

FAILED=false

askPortExpect hwi.ath.cx 25 "HELO" "SMTP"

echo

askPortExpect hwi.ath.cx 22 whatever "OpenSSH"

echo

## This one need only be tested if Hwi is runnign Gentoo, otherwise it's allowed to fail.
# askPortExpect hwi.ath.cx 222 whatever "OpenSSH"
# 
# echo

checkWebPageForRegexp "http://hwi.ath.cx/" "How to contact Joey"

echo

checkWebPageForRegexp "https://emailforever.net/cgi-bin/openwebmail/openwebmail.pl" "Open"

echo

checkWebPageForRegexp "http://generation-online.org/" "Generation"

echo

# doing "Checking hwi's port 5432 (postgres) is firewalled."
# nmap -p 5432 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

doing "Checking hwi's port 2049 (nfs) is firewalled."
nmap -p 2049 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

doing "Checking hwi's port 139 (samba) is firewalled."
nmap -p 139 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

doing "Checking hwi's port 445 (samba) is firewalled."
nmap -p 445 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

doing "Checking hwi's port 6000 (X:0) is firewalled."
nmap -p 6000 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

doing "Checking hwi's port 6001 (X:1) is firewalled."
nmap -p 6001 hwi.ath.cx 2>/dev/null | grep "[Oo]pen" && bad "Port is open!" || good "Port is not open"

echo

## Report result:

if [ "$FAILED" = false ]
then
	good "All tests passed.  =)"
else
	bad "There were failures.  Please fix or report.  (But first please run \"updatejsh\" to ensure you have the latest tests.)"
	exit 99
fi
