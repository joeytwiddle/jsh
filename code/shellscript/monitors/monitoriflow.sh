## Usage: monitoriflow [ <interface> ]
##   will display incoming, outcoming and total bytes per second travelling over the specified interface

## For floating point, we could use awk or perl, or bc as below.

getbytes () {
	/sbin/ifconfig "$IF" |
	grep "RX bytes" |
	sed 's+.*RX bytes:\([^ ]*\).*TX bytes:\([^ ]*\).*+\1 \2+g'
}

if [ "$1" ]
then IF="$1"
else IF=ppp0
fi

SLEEPING=2

while true
do

	# getbytes | read IN OUT
	IN=`getbytes | takecols 1`
	OUT=`getbytes | takecols 2`
	TIME=`date +"%s.%N"`
	# echo "$TIME $IN $OUT"

	sleep $SLEEPING
	[ $SLEEPING -lt 10 ] &&
		SLEEPING=`expr $SLEEPING '*' 2`

	# getbytes | read NEWIN NEWOUT
	NEWIN=`getbytes | takecols 1`
	NEWOUT=`getbytes | takecols 2`
	NEWTIME=`date +"%s.%N"`
	# echo "$NEWTIME $NEWIN $NEWOUT"

	DIN=`expr $NEWIN - $IN`
	DOUT=`expr $NEWOUT - $OUT`
	DSUM=`expr $DIN + $DOUT`
	DTIME=`echo "scale=0; $NEWTIME - $TIME" | bc`

	# BPS=`expr $DSUM / $DTIME`
	# BPSIN=`expr $DIN / $DTIME`
	# BPSOUT=`expr $DOUT / $DTIME`

	BPS=`echo "scale=0; $DSUM.0 / $DTIME" | bc`
	BPSIN=`echo "scale=0; $DIN.0 / $DTIME" | bc`
	BPSOUT=`echo "scale=0; $DOUT.0 / $DTIME" | bc`

	echo "$BPS bps ($BPSIN in, $BPSOUT out, over $DTIME"s")"

done
