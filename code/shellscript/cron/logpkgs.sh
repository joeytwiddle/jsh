#!/bin/sh
DATE=`date | sed 's/[^ ]*[ ]*\([^ ]*\)[ ]*\([^ ]*\)[ ]*[^ ]*[ ]*[^ ]*[ ]*\([^ ]\)/\2-\1-\3/'`
# DATE=today

if test "$1" = "-sizes"
then

	dpkgsizes | sort -n -k 1 > $JPATH/logs/debpkgs-sizes-$DATE.log
	cp $JPATH/logs/debpkgs-sizes-$DATE.log $JPATH/logs/debpkgs-sizes-today.log

else

	export COLUMNS=250
	dpkg -l "$@" > $JPATH/logs/debpkgs-list-$DATE.log
	cp $JPATH/logs/debpkgs-list-$DATE.log $JPATH/logs/debpkgs-list-today.log

	dpkg --get-selections > "$JPATH"/logs/dpkg-selections.$DATE

fi
