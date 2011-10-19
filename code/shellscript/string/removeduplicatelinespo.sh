#!/bin/sh
## Removes any duplicate lines from the stream, preserving line order on output.
## Doesn't remove empty lines.
## Keeps the first occurrence of a line, and drops any later occurrences.

LAST=""
cat "$@" |
## Can this awk be replaced by numbereachline?
awk ' {
        printf("%s",NR);
        printf("%s"," ");
        printf("%s",$0);
        printf("%s","\n");
      }
    ' |
# tee all |
## We do a stable sort so that the first column is not sorted
sort -s -k 2 |

escapeslash | ## echo "$LINE" below will lose any \s unless they are doubled up.  BUG: echo "$LINE" may lose other stuff too
# tee all_sorted |

while read N LINE
do
  # Ugh these three lines are a hack/fix for keepduplicatelines's gap mode!
  if [ "$LINE" = "" ]
  then
    echo "$N "
  elif [ ! "$LINE" = "$LAST" ]
  then
    echo "$N $LINE"
    LAST="$LINE"
  fi
done |
# tee final |
sort -n -k 1 |
afterfirst " "
