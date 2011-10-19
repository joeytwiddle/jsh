#!/bin/sh
# xdpyinfo | grep dimensions: | takecols 2
# xdpyinfo | grep dimensions: | grep -o "[0-9]*x[0-9]*" | head -n 1
# xdpyinfo | grep dimensions: | sed 's+.*dimensions:[ ]*++ ; s+ .*++'
xdpyinfo | grep dimensions: | sed 's+.*dimensions:[ ]*\([^ ]*\) .*+\1+'
