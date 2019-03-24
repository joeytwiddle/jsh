#!/bin/sh

if [ "$1" = "--help" ] || [ -z "$1" ]
then
	cat <<- !

		jshlockfile -f <filename> [ -release ]
		jshlockfile -i <identifier> [ -release ]

		TODO: Options to adjust timeout, and timeout actions (kill other process or not).

		TODO: Options to run a command, and release the lockfile afterwards.  (For use around a script rather than inside it.)

		TODO: Example usage.

		TODO: Recommend using trap to remove lockfile if script exits early.  http://stackoverflow.com/questions/1715137/the-best-way-to-ensure-only-1-copy-of-bash-script-is-running

	!
exit 0
fi

if [ "$1" = "-f" ]
then lockfile="$2" ; shift ; shift
fi

if [ "$1" = "-i" ]
then lockfile="/var/lock/$2.$USER" ; shift ; shift
fi

if [ -z "$lockfile" ]
then
	echo "Must provide -f or -i!" >&2
	exit 2
fi

if [ "$1" = -release ]
then

	rm -f "$lockfile"

else

	timeout_at=$(date -d "now + 5 seconds" +%s)

	while true
	do
		# BUG: This $$ is no use, it is the PID of jshlockfile, which is about to close.
		#      We need to get the running script to pass his PID to us, or just forget the idea of storing it.
		if ln -s "$$" "$lockfile" 2>/dev/null
		then
			# echo "Lockfile established" >&2
			break
		fi

		time_now=$(date +%s)
		if [ "$time_now" -gt "$timeout_at" ]
		then
			echo "Could not wait any longer for $lockfile to release." >&2
			# TODO: Optionally, kill other process.
			kill -9 $(readlink "$lockfile")
			ln -sf "$$" "$lockfile"
			break
			# TODO: Optionally, quit rather than force.
			#exit
		fi

		sleep 0.2
	done

fi



exit

# How to use flock?

# Easiest method: Use it from *outside* a script / command:
# flock <options> <command>...

# Harder method: Use it inside a running shellscript:

LMT_REQ_LOCK="/var/lock/lmt-req.lock"
LMT_INVOC_LOCK="/var/lock/lmt-invoc.lock"

# Check and acquire locks and then exec.
exec 8>$LMT_REQ_LOCK;
if $FLOCK -n -x -w 1 8; then
	log "VERBOSE" "Prelim lock acquisition on descriptor 8 with pid $$";
else
	log "VERBOSE" "Couldn't acquire prelim lock on descriptor 8 with pid $$";
fi

exec 9>$LMT_INVOC_LOCK;
if $FLOCK -n -x -w 1 9; then
	$FLOCK -u 8; ## Release the invoc lock;
	log "VERBOSE" "Prelim lock acquisition on descriptor 9 with pid $$";
	log "VERBOSE" "Now invoking lmt_main_function with arguments -- $@";
	lmt_main_function "$@";
else
	log "VERBOSE" "Couldn't acquire prelim lock on descriptor 9 with pid $$";
	log "VERBOSE" "Now invoking lock_retry with arguments -- $@";
	lock_retry "$@";
fi

$FLOCK -u 8;
$FLOCK -u 9;

