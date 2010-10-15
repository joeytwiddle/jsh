#!/bin/sh
## jsh-help: Like find "$1" -type f, but does not bomb when encountering "Stale NFS file handle"
## jsh-help: I used to get that problem occasionally on a vfat mount I used.

# cd "$1" || . errorexit "Could not enter directory $1"
# [ -e "$1" ] || . errorexit "Does not exist: $1"
'ls' "$1" -a -R | ls-Rtofilelist | filesonly
