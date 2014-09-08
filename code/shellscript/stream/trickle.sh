#!/bin/bash

## See also: slowcp, catslowly

## TODO: catslowly should really work if provided a file as args!  Maybe this could too.

## TODO: could (optionally) check hardisk usage (/proc/partitions) to and adjust its runtime byterate accordingly.

# Bytes per second
SPEED="1000"
SLEEPTIME=1

if [ "$1" = -at ]
then SPEED="$2"; shift; shift
fi

if [ "$1" = -n ] || [ "$1" = --interval ]
then SLEEPTIME="$2"; shift; shift
fi

COUNT=1

SOFAR=0

## I did wonder whether repeated calls to dd, sleep and expr might be causing drive accesses.
## I tried copying them all to /dev/shm/bin and adding that to the front of my PATH.  But my experiments were inconclusive!

while dd count=$COUNT bs=$SPEED 2>/dev/null
do
	wait
	sleep $SLEEPTIME &
	[ -n "$SOFAR" ] && SOFAR=`expr $SOFAR + '(' $SPEED '*' $COUNT ')'` || SOFAR=
	# [ "$SOFAR" ] &&

	if [ -n "$TRICKLE_SHOW_PROGRESS" ]
	then
		echo -e -n '\r[ ' >&2
		echo -n "$SOFAR / $KNOWN_TOTAL_SIZE" >&2
		[ -n "$SOFAR" ] && [ -n "$KNOWN_TOTAL_SIZE" ] && echo -n " : `expr 100 '*' $SOFAR / $KNOWN_TOTAL_SIZE` %" >&2
		echo -n " ]  " >&2
	fi

	if [ -n "$SOFAR" ] && [ -n "$KNOWN_TOTAL_SIZE" ] && [ "$SOFAR" -gt "$KNOWN_TOTAL_SIZE" ]
	then
		jshinfo "trickle dropping out after KNOWN_TOTAL_SIZE reached (because dd didn't!)."
		break
	fi
done
