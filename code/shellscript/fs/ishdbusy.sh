#!/bin/sh
# this-script-does-not-depend-on-jsh: write
# jsh-depends: takecols

## TODO: depend on (and farm off stuff to) monitorhdflow | head

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "ishdbusy [ -v ] [ <hd#> ]+"
	echo "  will return true (0) if any of the specified drives are undergoing read or write operations."
	echo "  TODO: ok actually this is a lie - it currently only checks read data."
	exit 0
fi

if [ "$1" = -v ]
then VERBOSE=true; shift
fi

## I use /proc/partitions to get info about drive / partition / channel / whatever usage.
## To experiment yourself, try: jwatchchanges -fine "cat /proc/partitions | columnise"

getreadcount () {
	cat /proc/partitions |
	grep "ide/host0/bus0/target$HDN/lun0/disc" |
	# major minor  #blocks  name     rio rmerge rsect ruse wio wmerge wsect wuse running use aveq
	# 1     2      3        4        5   6      7     8    9   10     11    12   13      14  15
	# takecols 5
	while read major minor  blocks  name     rio rmerge rsect ruse wio wmerge wsect wuse running use aveq
	do
		# expr "$rio" + "$wio"
		echo "$rio" ## Hack for resume_bittorrent_downloads
		break
	done
}

MAXDIFF=30
## Now that we are including wio:
# MAXDIFF=50

for HDN
do

	COUNTA=`getreadcount`
	sleep 5
	COUNTB=`getreadcount`
	DIFF=`expr $COUNTB - $COUNTA`

	[ "$VERBOSE" ] && echo "$HDN: $DIFF"

	## is this partition busy?
	if [ "$DIFF" -gt "$MAXDIFF" ]
	then exit 0
	fi

done

## no partitions were busy
exit 1
