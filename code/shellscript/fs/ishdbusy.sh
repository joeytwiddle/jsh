if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "ishdbusy [ -v ] [ <hd#>/<partition#> ]+"
	echo "  will return true if any of the specified partitions are undergoing read operations."
	exit 0
fi

if [ "$1" = -v ]
then VERBOSE=true; shift
fi

getreadcount () {
	cat /proc/partitions |
	grep "ide/host0/bus0/target$HDN/lun0/part$PARTN" |
	# major minor  #blocks  name     rio rmerge rsect ruse wio wmerge wsect wuse running use aveq
	# 1     2      3        4        5   6      7     8    9   10     11    12   13      14  15
	takecols 14
}

MAXDIFF=100

for PSPEC
do

	HDN=`echo "$PSPEC" | before /`
	PARTN=`echo "$PSPEC" | after /`

	COUNTA=`getreadcount`
	sleep 5
	COUNTB=`getreadcount`
	DIFF=`expr $COUNTB - $COUNTA`

	[ "$VERBOSE" ] && echo "$HDN/$PARTN: $DIFF"

	## is this partition busy?
	if [ "$DIFF" -gt "$MAXDIFF" ]
	then exit 0
	fi

done

## no partitions were busy
exit 1
