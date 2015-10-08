#!/bin/sh
# myps -A | sort -n -k 6 | tail "$@"
ps -o time,ppid,pid,nice,pcpu,pmem,user,args -A | grep "$1" | sort -n -k 6 | tail -n 15

# We can sum the memory used by multiple threads of a single task, e.g.:
#   | g chromium-browse | takecols 6 | awksum
# but how to automate this to provide --aggregate ?
# I suppose we should extract process names on the first run, loop and aggregate each.
