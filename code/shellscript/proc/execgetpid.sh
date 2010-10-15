#!/bin/sh
# jsh-ext-depends-ignore: start-stop-daemon
# this-script-does-not-depend-on-jsh: pid jdeltmp jgettmp
## TODO:
## The fluxbox xinitrc HOWTO mentions:
# wmaker & wmpid=$!
## will store wmaker's new PID nice one!
## TODO: yeah dd man page mentions it too: use thet method!

"$@" >&2 &

PID="$!"

echo "$PID"
exit

### Old method:
# OLD jsh-depends: jdeltmp jgettmp
# OLD jsh-depends-ext: jdeltmp jgettmp start-stop-daemon

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
