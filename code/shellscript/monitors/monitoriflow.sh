# jsh-ext-depends-ignore: over

# jsh-depends: takecols
# jsh-ext-depends: bc sed ifconfig

## TODO: deal with rollover of numbers.  easily detectable (new < last), but how much do we add (~1213030)

## Needed to use bc because expr cannot process floating point, but alternatively could have tried awk or perl.

if [ "$1" = --help ]
then
cat << !

monitoriflow [ -window <seconds> ] [ -tc <qdisc_num> ] [ <interface> ]

  will display incoming, outgoing and total average bytes per second
  travelling over the specified interface (or eth1 by default).

  With the -tc option, will display mean outgoing bps over the specified qdisc.

  The window used to take measurements gets larger until it reaches 30 seconds.

!
exit
fi

getbytesifconfig () {
	/sbin/ifconfig "$IFACE" |
	grep "RX bytes" |
	sed 's+.*RX bytes:\([^ ]*\).*TX bytes:\([^ ]*\).*+\1 \2+g'
}

getbytestc () {
	echo -n "0 "
	/sbin/tc -s qdisc ls dev $IFACE |
	grep -A1 " $DISCNUM:" |
	tail -n 1 |
	# pipeboth |
	takecols 2 # | pipeboth
}

WINDOW=30
if [ "$1" = -window ]
then
	WINDOW="$2"
	shift; shift
fi

GETBYTESIO=getbytesifconfig
if [ "$1" = -tc ]
then
	GETBYTESIO=getbytestc
	DISCNUM="$2"
	shift; shift
	if [ ! "$DISCNUM" ]
	then error "You must also provide a <qdisc_num>"; exit 2
	fi
fi

if [ "$1" ]
then IFACE="$1"
# else IFACE=ppp0
else
	IFACE=eth1
	if ! /sbin/ifconfig $IFACE > /dev/null
	then IFACE=eth0
	fi
fi

SLEEPFOR=1

FIRSTRUN=true

## Check the interface is up:
if ! /sbin/ifconfig $IFACE > /dev/null
then
	error "Interface $IFACE does not exist."; exit 3
fi

while true
do

	wait
	sleep $SLEEPFOR &

	# $GETBYTESIO | read NEWIN NEWOUT
	NEWIN=`$GETBYTESIO | takecols 1`
	NEWOUT=`$GETBYTESIO | takecols 2`
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

		if [ "$BPS" -lt 0 ]
		then echo "Readings obscured by counter rollover" >&2
		else echo "$BPS bps ($BPSIN in, $BPSOUT out, over $DTIME"s")"
		fi

		SLEEPFOR=`expr $SLEEPFOR '*' 2`
		if [ $SLEEPFOR -gt "$WINDOW" ]
		then SLEEPFOR="$WINDOW"
		fi

	fi

	# $GETBYTESIO | read OLDIN OLDOUT
	OLDIN="$NEWIN"
	OLDOUT="$NEWOUT"
	OLDTIME="$NEWTIME"

done
