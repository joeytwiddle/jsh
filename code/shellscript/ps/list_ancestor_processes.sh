#!/bin/sh

pid="$1"

if [ "$pid" = "" ]
then
cat << !

list_ancestor_processes <pid>

Goal: Given PID, list this process, and parent process, and his parent, ... (in reverse/chronological order)

Current implementation is a dodgy approximation, using pstree and grep.

CONSIDER: Could be renamed 'show_call_stack' or 'show_stack_trace'

Example usage:

If a script is getting called on your system, but you don't know why, you could log the calling process by adding to the top of the script.

    {
      echo
      echo "$0 $* was called by..."
      /home/joey/j/jsh list_ancestor_processes $$
    } >> /tmp/script_caller.log

!
exit 1
fi

# Simplistic implementation, placeholder
env COLUMNS=65535 myps -A --forest |
grep -B 10 "^[^ ]* *[^ ]* *$pid"
