## TODO:
## The fluxbox xinitrc HOWTO mentions:
# wmaker & wmpid=$!
## will store wmaker's new PID nice one!

BINARY="$1"
shift
PIDFILE=`jgettmp "pid for $BINARY"`

/sbin/start-stop-daemon --start -b -m -p $PIDFILE -a "$BINARY" -- "$@" >&2

for SLEEPFOR in 0 1 5 15
do
	sleep $SLEEPFOR
	PID=`cat $PIDFILE`
	if [ "$PID" ]
	then
		echo "$PID"
		jdeltmp $PIDFILE
		exit 0
	fi
done

jdeltmp $PIDFILE
exit 1
