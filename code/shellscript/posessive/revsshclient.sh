## Note - this script shares files with the revssh CGI script.
## On my sys, this means it must run as www-data.
## No longer true - they work together fine now, because the files are
## only written to by one of the processes.
## It does however mean that the www-data user must be accessed in order to clean up!  TODO: put cleanup in CGI script

## Uses for revssh...
## Well you can run most shell commands (maybe not "cat"!), but ...
##   BUG: fixable? You can't send Ctrl+D or Ctrl+C or Ctrl+Z
##   BUG: you can't run standard editors because the remote shell is non-interactive
##   BUG: programs won't let u type passwords because the remote shell is non-interactive
## This last bug is especially annoying, because it prevents you from su'ing to root, or ssh'ing out (for example to create a port-forward allowing you to ssh in to the machine's previously hidden sshd).
## However, revssh does give you enough power to:
##  set up RSA so you don't need a password to ssh out (tocheck: I think this has to work first time or you lost the revssh session, because if it does ask for a password then the session blocks).
##  or, export an xterm across the ether

function indent() {
	sed 's+^+  +'
}

echo "The following hosts have tried to initiate revssh sessions:"
ATTEMPTS=`ls /tmp/revssh-host-*.off | sed 's+^/tmp/revssh-host-++;s+\.off$++'`
echo "$ATTEMPTS" | indent
if [ "$ATTEMPTS" ]
then
	echo
	echo "To enable one, type one of the following:"
	echo "$ATTEMPTS" |
	sed 's+\(.*\)+touch /tmp/revssh-host-\1.on+' |
	indent
fi

SESSID="$1"
if [ ! "$SESSID" ]
then
	echo
	if ! ls -l /tmp/revssh-client-input-*.txt
	then
		echo "There are no open connections at this time."
		exit 1
	fi
	echo "Choose which session to join:"
	ls /tmp/revssh-client-input-*.txt |
	sed "s+^/tmp/revssh-client-input-++;s+\.txt$++" |
	indent
	read SESSID
fi

echo "Waiting to join $SESSID..."

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
