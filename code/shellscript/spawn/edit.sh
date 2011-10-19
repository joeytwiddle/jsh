#!/bin/sh
# jsh-depends: editandwait xisrunning

## When edit is used in a GUI, e.g. called from the browser, then we should not
## return until the editing session is complete (like vim and other editors).
## Currently we don't do this.  I have told my browser to use editandwait.

## If edit is used from a terminal, then our behaviour will depend on whether
## we are in a GUI or not.  With no GUI, we must run a terminal editor (e.g.
## pico or vi) in the foreground; but in a GUI environment, we probably want an
## editor to pop up in a new window, and control returned to the commandline.
## That is what we check here:

if xisrunning
then
	editandwait "$@" &

## If we using screen, then it might be nice to popup an editor in a new window, and leave our current shell usable.
## BUG TODO: screen -X loses our shell env including PWD, which is bad for local filenames and external executions from the editor.  Set the WD!
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
