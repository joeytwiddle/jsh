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

if [ "$1" = -join ]
then

	SESSID="$2"; shift; shift

	echo "Joining session $SESSID ..."

	tail -f /tmp/revssh-client-output-$SESSID.txt |
	while read X; do
		printf "\033[00;32m"
		echo "$X"
		printf "\033[0m"
	done &

	## TODO: these appear to be killed when the session is exited with Ctrl+C, which is good!
	( while true; do echo >> /tmp/revssh-client-input-$SESSID.txt ; sleep 10 ; done ) &

	## Pass user input to remote shell (well, leave it in file for CGI script to
	## pass to remote revsshserver when it makes http request)
	cat >> /tmp/revssh-client-input-$SESSID.txt

	wait

elif [ "$1" = -wait ]
then

	TARGETHOST="$2"; shift; shift
	
	echo "Waiting for a fresh connection to $TARGETHOST"
	# echo "TODO: you have to touch the .on file before this is worthwhile."

	touch /tmp/revssh-host-$TARGETHOST.on

	while true
	do
		# OLD=`memo         ls "/tmp/revssh-client-output-$TARGETHOST*" 2>/dev/null`
		# NOW=`memo -c true ls "/tmp/revssh-client-output-$TARGETHOST*" 2>/dev/null`
		# OLD=`memo         ls "/tmp/revssh-client-output-$TARGETHOST*"`
		# NOW=`memo -c true ls "/tmp/revssh-client-output-$TARGETHOST*"`
		OLD=`memo         ls /tmp | grep "revssh-client-output-$TARGETHOST"`
		NOW=`memo -c true ls /tmp | grep "revssh-client-output-$TARGETHOST"`
		# echo
		# echo "OLD="
		# echo "$OLD"
		# echo
		# echo "NEW="
		# echo "$NEW"
		# echo
		if [ "$OLD" ]
		then
			KILLRE=`echo "$OLD" | list2regexp` ## removed -n cos it was dropping last line!  Maybe trimempty would be more suitable than -n
			# echo "KILLRE="
			# echo "$KILLRE"
			# echo
			NEW=`echo "$NOW" | grep -v "$KILLRE"`
		else
			NEW="$NOW"
		fi
		echo "--------------------------------"
		echo "$OLD"
		echo "------------------"
		echo "$NOW"
		echo "==========="
		echo "$NEW"
		echo "......."
		[ "$NEW" ] && break
		sleep 10
	done

	SESSID=`echo "$NEW" | head -n 1 | afterlast - | beforefirst "\."`

	echo "OK, joining session: $SESSID"
	echo "You may want to: rm /tmp/revssh-host-$TARGETHOST.on"
	echo

	rm /tmp/revssh-host-$TARGETHOST.on ## Neat =)

	revsshclient -join "$SESSID"

else

	ls -l /tmp/revssh-host-*.off | dropcols 1 2 3 4
	echo "The following hosts have tried to initiate revssh sessions:"
	ATTEMPTS=`ls /tmp/revssh-host-*.off | sed 's+^/tmp/revssh-host-++;s+\.off$++'`
	echo "$ATTEMPTS" | indent
	if [ "$ATTEMPTS" ]
	then
		echo
		# echo "To enable one, type one of the following:"
		# echo "$ATTEMPTS" |
		# sed 's+\(.*\)+touch /tmp/revssh-host-\1.on+' |
		# ## Move is not possible since .off file was created by the www user (cgi)
		# # sed 's+\(.*\)+mv /tmp/revssh-host-\1.off /tmp/revssh-host-\1.on+' |
		# indent
		echo "Which box do you want to join?"
		read TARGETHOST
		if [ "$TARGETHOST" ]
		then revsshclient -wait "$TARGETHOST"
		fi
	fi

	# SESSID="$1"
	# if [ ! "$SESSID" ]
	# then
		# echo
		# if ! ls -l /tmp/revssh-client-input-*.txt
		# then
			# echo "There are no open connections at this time."
			# exit 1
		# fi
		# echo "Choose which session to join:"
		# ls /tmp/revssh-client-input-*.txt |
		# sed "s+^/tmp/revssh-client-input-++;s+\.txt$++" |
		# indent
		# read SESSID
	# fi

	# revsshclient -join "$SESSID"

fi
