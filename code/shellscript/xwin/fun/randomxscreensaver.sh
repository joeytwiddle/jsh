## Problems:
#   ok so we don't create if kill fails
#   but sometimes creation fails!
#   recommend using mykillps or something to count instances and then kill or create to meet target.

NUM=4
if [ "$1" ]
then NUM="$1"; shift
fi
XSCRBINS=/usr/lib/xscreensaver

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
	sleep 10
	# PIDTOKILL=`echo -n "$PIDS" | grep -v '^$' | chooserandomline`
	PIDTOKILL=`mykillps -x "$XSCRBINS" | takecols 1 | chooserandomline`
	echo kill -KILL "$PIDTOKILL"
	if kill -KILL "$PIDTOKILL"
	then
		PIDS=`echo -n "$PIDS" | grep -v "^$PIDTOKILL$"`
		CHOSEN=`chooserandomxscreensaverhack`
		echo "Starting $CHOSEN"
		NEWPID=`execgetpid "$CHOSEN" -root`
		PIDS="$PIDS$NL$NEWPID"
		# ( sleep 60; kill -KILL $NEWPID ) &
	fi
done

echo "Killing all"

echo -n "$PIDS" |
while read PIDTOKILL
do kill -KILL "$PIDTOKILL"
done
