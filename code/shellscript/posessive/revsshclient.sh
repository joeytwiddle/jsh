## Note - this script shares files with the revssh CGI script.
## On my sys, this means it must run as www-data.
## No longer true - they work together fine now, because the files are
## only written to by one of the processes.

function indent() {
	sed 's+^+  +'
}

echo "The following hosts have tried to initiate revssh sessions:"
ls /tmp/revssh-host-* | indent

SESSID="$1"
if [ ! "$SESSID" ]
then
	echo
	echo "Choose which session to join:"
	ls /tmp/revssh-client-input-*.txt |
	sed "s+^/tmp/revssh-client-input-++;s+\.txt$++" |
	indent
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
