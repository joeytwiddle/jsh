#!/bin/sh

## TODO: no locking

## For a fresh installation, do the following as root:
# touch /var/logadmin.log
# chgrp users /var/logadmin.log
# chmod g+w /var/logadmin.log
## And optionally:
# chgrp users /etc/motd
# chmod g+w /etc/motd

LOGFILE="/var/logadmin.log"

display_log () {

	echo
	printf "\033[00;32m" # green
	printf "Welcome to `hostname`.  "
	printf "\033[00;36m" # cyan
	printf "Here follows the adminlog:"
	echo
	echo

	printf "\033[00m" # normal
	cat $LOGFILE |
	sed 's+................................................................................+\0\
+g' |
	tail -14

	echo
	printf "\033[00;36m" # cyan
	echo "To add to the admin log, type: adminlog add"
	echo "The full log is available from: $LOGFILE"

	printf "\033[00m" # normal
	echo

}

TMPFILE="/tmp/logentry.tmp"
while test -e "$TMPFILE"; do
	TMPFILE=$TMPFILE"-"
done
touch $TMPFILE

if [ "$1" = "add" ]
then

	# New entry
	echo "Please enter your message then press Ctrl+D:"
	echo "If you don't want to make a log entry, press Ctrl+C."
	cat >> $TMPFILE || ( rm $TMPFILE && exit 0 )
	(
		echo
		cat $TMPFILE
		echo "  -- $USER ("`date`")"
	) >> $LOGFILE
	echo "Ok entered =)  The new logfile follows:"
	rm $TMPFILE

fi

display_log |

if ( [ "$1" = "add" ] || [ "$1" = "update" ] ) && [ -w /etc/motd ]
then
	cat > /etc/motd
	cat /etc/motd
else
	cat
fi
