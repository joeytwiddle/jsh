#!/usr/local/bin/zsh

# Derive j/ path from execution of this script

# What about $_ absolute (bash at least)?
POSSTOOLDIR=`dirname "$0"`
POSSJDIR=`dirname "$POSSTOOLDIR"`
POSSJDIR2=`echo "$POSSTOOLDIR" | sed "s+j/.*+j/+"`

# Collect all the paths we might try to find j/ in

TRYDIRS="$POSSJDIR
$HOME/j
/home/joey/j
/home/joey/linux/j
/home/pgrad/pclark/j"

# Perform the search

export DONE="false" # this is for #!/bin/sh but not working yet

set > /home/joey/j/tmp/jrun.envb4

echo "$TRYDIRS" | while read X; do
	echo "Trying >$X< $DONE"
	if test "$DONE" = "false"; then
		if test -d "$X"; then
			if test -x "$X/startj"; then
				echo "Going for >$X<" >> /home/joey/j/tmp/jrun.log
				# exec $X/startj
				# source $X/startj
				# . $X/startj
				echo A
				. $X/code/shellscript/init/startj-hwi.sh simple
				echo B
				set > /home/joey/j/tmp/jrun.env
				"$@"
				RES="$?"
				export DONE="true";
				echo "Exiting with $RES"
				exit "$RES"
			fi
		fi
	fi
done

if test "$DONE" = "false"; then
	echo "jrun: Can't find your j installation in any of:"
	echo "$TRYDIRS"
	echo "Sorry!"
	exit 1
fi
