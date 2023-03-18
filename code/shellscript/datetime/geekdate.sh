#!/usr/bin/env bash

## Returns a fixed-length date string suitable for computer use, because simple string-ordering of these strings will correspond to chronological order.
## See also: date -I
if [ "$1" = -seconds ]
then shift; date +"%Y%m%d-%H-%M-%S" "$@"
elif [ "$1" = -fine ] || [ "$1" = -minutes ]
then shift; date +"%Y%m%d-%H%M" "$@"
else date +"%Y%m%d" "$@"
fi
