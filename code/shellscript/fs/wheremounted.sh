#!/bin/sh
## See also: /bin/mountpoint -d (not available in morphix)
# jsh-depends: takecols drop flatdf
# jsh-ext-depends: sort realpath

DIR=`realpath "$1"`

flatdf 2>/dev/null | drop 1 | takecols 6 |

# Choose the longest matching one (/mnt/foo over /):
sort -r |
while read MOUNTPNT
do
  echo "$DIR" | grep "^$MOUNTPNT" > /dev/null &&
  echo "$MOUNTPNT"
done | head -n 1

