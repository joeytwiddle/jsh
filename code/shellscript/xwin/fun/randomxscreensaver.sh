# jsh-ext-depends: find seq xscreensaver
# jsh-depends: chooserandomline execgetpid mykill takecols psforkillchild mykillps
## Problems:
#   ok so we don't create if kill fails
#   but sometimes creation fails!
#   recommend using mykillps or something to count instances and then kill or create to meet target.

XSCRBINS=/usr/lib/xscreensaver

NUM=4
if [ "$1" ]
then NUM="$1"; shift
fi

NL='
'

chooserandomxscreensaverhack () {
	find "$XSCRBINS" -perm +u+x |
	chooserandomline
}

findchildprocs () {
	psforkillchild | grep "6[ 	]*$1[ 	]"
}

echo "Copy this to your clipboard.  It is needed to stop the hacks when you break out."
echo "  echo | mykill -x $XSCRBINS"

for X in `seq 1 $NUM`
do
	CHOSEN=`chooserandomxscreensaverhack`
	echo "Starting $CHOSEN"
	NEWPID=`execgetpid "$CHOSEN" -root`
	PIDS="$PIDS$NL$NEWPID"
	# ( sleep 60; kill -KILL $NEWPID ) &
done

while true
do
	sleep 2
	RUNNINGPIDS=`mykillps -x "$XSCRBINS" | takecols 1`
	NUMRUNNINGPIDS=`echo -n "$RUNNINGPIDS" | countlines`
	echo "$NUMRUNNINGPIDS"
	if [ ! "$NUMRUNNINGPIDS" -lt "$NUM" ]
	then
		PIDTOKILL=`echo "$RUNNINGPIDS" | head -1` ## Evenly rotate by killing oldest every time
		echo kill -KILL "$PIDTOKILL"
		kill -KILL "$PIDTOKILL"
	fi
	sleep 1
	CHOSEN=`chooserandomxscreensaverhack`
	echo "Starting $CHOSEN"
	NEWPID=`execgetpid nice -n 20 "$CHOSEN" -root`
done

echo "Killing all"

echo -n "$PIDS" |
while read PIDTOKILL
do kill -KILL "$PIDTOKILL"
done
