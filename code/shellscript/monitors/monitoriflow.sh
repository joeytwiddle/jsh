# jsh-depends: takecols
# jsh-ext-depends: bc
## Usage: monitoriflow [ <interface> ]
##   will display incoming, outcoming and total bytes per second travelling over the specified interface

## TODO: deal with rollover of numbers which apparently happens as one woule expect

## For floating point, we could use awk or perl, or bc as below.

getbytes () {
	/sbin/ifconfig "$IFACE" |
	grep "RX bytes" |
	sed 's+.*RX bytes:\([^ ]*\).*TX bytes:\([^ ]*\).*+\1 \2+g'
}

if [ "$1" ]
then IFACE="$1"
# else IFACE=ppp0
else IFACE=eth1
fi

SLEEPFOR=1

FIRSTRUN=true

## Check the interface is up:
if ! /sbin/ifconfig $IFACE > /dev/null
then exit
fi

while true
do

	# getbytes | read NEWIN NEWOUT
	NEWIN=`getbytes | takecols 1`
	NEWOUT=`getbytes | takecols 2`
	# NEWTIME=`date +"%s.%N"`
	NEWTIME=`date +"%s.%N" | sed 's+\(.*\....\).*+\1+'`
	# echo "$NEWTIME $NEWIN $NEWOUT"

	if [ $FIRSTRUN ]
	then FIRSTRUN=
	else

		DIN=`expr $NEWIN - $OLDIN`
		DOUT=`expr $NEWOUT - $OLDOUT`
		DSUM=`expr $DIN + $DOUT`
		DTIME=`echo "scale=0; $NEWTIME - $OLDTIME" | bc`

		# BPS=`expr $DSUM / $DTIME`
		# BPSIN=`expr $DIN / $DTIME`
		# BPSOUT=`expr $DOUT / $DTIME`

		BPS=`echo "scale=0; $DSUM.0 / $DTIME" | bc`
		BPSIN=`echo "scale=0; $DIN.0 / $DTIME" | bc`
		BPSOUT=`echo "scale=0; $DOUT.0 / $DTIME" | bc`

		echo "$BPS bps ($BPSIN in, $BPSOUT out, over $DTIME"s")"
		if [ $SLEEPFOR -lt 32 ]
		then SLEEPFOR=`expr $SLEEPFOR '*' 2`
		fi

	fi

	# getbytes | read OLDIN OLDOUT
	OLDIN="$NEWIN"
	OLDOUT="$NEWOUT"
	OLDTIME="$NEWTIME"

	sleep $SLEEPFOR

done
