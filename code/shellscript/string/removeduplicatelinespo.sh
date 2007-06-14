## Removes any duplicate lines from the stream, preserving line order on output.
## Doesn't remove empty lines

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
sort -k 2 |

escapeslash | ## echo "$LINE" below will lose any \s unless they are doubled up.  BUG: echo "$LINE" may lose other stuff too

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
sort -n -k 1,1 |
afterfirst " "
