SPEED="1K"

if [ "$1" = -at ]
then SPEED="$2"; shift; shift
fi

SOFAR=0

while dd count=1024 bs=$SPEED 2>/dev/null
do
	wait
	[ "$SOFAR" ] && SOFAR=`expr $SOFAR + $SPEED` || SOFAR=
	# [ "$SOFAR" ] &&
	echo "$SOFAR / $KNOWN_TOTAL_SIZE" >&2
	sleep 1 &
done
