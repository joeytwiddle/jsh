#!/bin/sh
# jsh-depends: editandwait xisrunning

if xisrunning
then
	editandwait "$@" &

## Safe as fuck!  Pops it up in a new screen window:
## OK, except a lot of the time I'd rather prioritise X (which doesn't get checked until editandwait!)
## TODO: also, screen -X loses our shell env including PWD, which is bad for local filenames and external executions from the editor.  Set the WD!
elif [ "$STY" ]
then
	## spawned shell may not have same PWD, so:
	## BUG: this doesn't work for new files because of the [ -f "$X" ] check.
	for X
	do [ -f "$X" ] && realpath "$X" || echo "$X"
	done |
	withalldo screen -X screen editandwait

else
	editandwait "$@"

fi
