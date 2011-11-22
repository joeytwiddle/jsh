#!/bin/sh
SECURITY_LIST=/etc/apt/sources-security.list

if [ ! -f "$SECURITY_LIST" ]
then
	echo "Generating $SECURITY_LIST"
	cat /etc/apt/sources.list  | grep security > "$SECURITY_LIST"
fi

# apt-get --option Dir::Etc::sourcelist="$SECURITY_LIST" upgrade
aptitude -o Dir::Etc::sourcelist="$SECURITY_LIST" upgrade

