# jsh-ext-depends: find seq xscreensaver
# jsh-depends: chooserandomline execgetpid mykill takecols psforkillchild mykillps
## Problems:
#   ok so we don't create if kill fails
#   but sometimes creation fails!
#   recommend using mykillps or something to count instances and then kill or create to meet target.

## TODO: optionally select only screensavers present and turned on in users ~/.xscreensaverrc (use grep)
## TODO: optionally avoid all hacks which flush a screenbuffer ( => flicker )
##       or other unsuitable / rubbish hacks

XSCRBINS=/usr/lib/xscreensaver

NUM=4
if [ "$1" ]
then NUM="$1"; shift
fi

NL='
'

chooserandomxscreensaverhack () {
	find "$XSCRBINS" -perm +u+x |
	## This sh call was used so that if chooserandomline is imported as a function, the seed $$ changes.
	# sh chooserandomline
	## But it broke if chooserandomline was imported as a function, and now randomorder uses date as seed.
	chooserandomline
}

findchildprocs () {
	psforkillchild | grep "6[ 	]*$1[ 	]"
}

getrunningpids () {
	mykillps -x "$XSCRBINS" | takecols 1
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
	NUMRUNNINGPIDS=`getrunningpids | countlines`
	echo "$NUMRUNNINGPIDS / $NUM"

	if [ ! "$NUMRUNNINGPIDS" -lt "$NUM" ]
	then
		PIDTOKILL=`getrunningpids | head -n 1` ## Evenly rotate by killing oldest every time
		echo "Killing $PIDTOKILL"
		# echo kill -KILL "$PIDTOKILL"
		kill -KILL "$PIDTOKILL" || echo "kill -KILL $PIDTOKILL FAILED!"
	fi

	sleep 1

	NUMRUNNINGPIDS=`getrunningpids | countlines`
	if [ "$NUMRUNNINGPIDS" -lt "$NUM" ]
	then
		CHOSEN=`chooserandomxscreensaverhack`
		echo "Starting $CHOSEN"
		NEWPID=`execgetpid nice -n 20 "$CHOSEN" -root`
		[ "$NEWPID" ] || echo "Start failed!" ## not likely to happen
	fi

done

echo "Killing all"

echo -n "$PIDS" |
while read PIDTOKILL
do kill -KILL "$PIDTOKILL"
done
