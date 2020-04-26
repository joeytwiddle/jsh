#!/usr/bin/env bash

#journalctl -x -f -b 0 -n 1000

# Instead of running the command, we display it, to encourage the user (me) to learn the commands
cat << !

Try: journalctl -x -f -b 0 -n 1000

or to watch output from a particular unit:

sudo journalctl -f -u earlyoom

!
