## Note - this script shares files with the revssh CGI script.
## On my sys, this means it must run as www-data.

SESSID="$1"
if test ! "$SESSID"; then
	echo "Choose which session to join:"
	ls /tmp/revssh-client-input-*.txt |
	sed "s+^/tmp/revssh-client-input++;s+\.txt$++"
	read SESSID
fi

tail -f /tmp/revssh-client-output-$SESSID.txt |
while read X; do
	printf "\033[00;32m"
	echo "$X"
	printf "\033[0m"
done &

## Pass user input to remote shell (well, leave it in file for CGI script to
## pass to remote revsshserver when it makes http request)
cat >> /tmp/revssh-client-input-$SESSID.txt

wait
