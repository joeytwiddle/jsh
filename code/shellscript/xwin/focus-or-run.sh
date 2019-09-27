#!/usr/bin/env bash

# Focus the given application if it is already running, otherwise run it!
#
# Examples:
#
#     focus-or-run firefox
#
#     focus-or-run -p "chrome" google-chrome
#
# With some help from github:ronjouch/marathon
#
# See also: run-or-raise

# Pass -p if the name of the process is different from the name of the executable you call to start it
if [ "$1" = -p ]
then
    search_proc="$2"
    shift ; shift
fi

if [ -z "$search_proc" ]
then search_proc="$1"
fi

pid="$(pgrep -u "$UID" "$search_proc" | head -n 1)"

if [ -n "$pid" ]
then
    # This doesn't work because wmctrl does not list the process name, only its wm_class and its title.
    #winid="$(wmctrl -l -x | takecols 1 3 | fgrep " ${search_proc}" | head -n 1 | takecols 1)"
    #if [ -n "$winid" ]
    #then wmctrl -a "$winid"
    #else echo "Found process $pid but could not find $search_proc in wmctrl -l -x" >&2
    #fi
    # Find by wm_class
    wmctrl -x -a "$search_proc" ||
    # Find by title
    wmctrl -a "$search_proc"
else
    exec "$@"
fi
