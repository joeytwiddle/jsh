#!/bin/sh
## See also: /bin/mountpoint -d (not available in morphix)
# jsh-ext-depends: sort realpath
# jsh-depends: takecols drop realpath
DIR=`realpath "$1"`

flatdf 2>/dev/null | drop 1 | takecols 6 |

# Choose the longest matching one (/mnt/foo over /):
sort -r |
while read MOUNTPNT
do
  echo "$DIR" | grep "^$MOUNTPNT" > /dev/null &&
  echo "$MOUNTPNT"
done | head -n 1

