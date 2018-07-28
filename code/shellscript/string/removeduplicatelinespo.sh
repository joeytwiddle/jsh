## Removes any duplicate lines from the stream, preserving line order on output.
## Keeps the first occurrence of a line, and drops any later occurrences.

# Efficient awk version
# Unfortunately, this does not work well with findduplicatefiles, because it strips empty lines.
# In fact stripping duplicated empty lines would usually be the expected behaviour!
# But we made some exceptional behaviour for empty lines below, to assist keepduplicatelines -gap, which findduplicatefiles uses.
#awk '!already_seen[$0]++' "$@"
#exit

## From http://unix.stackexchange.com/questions/194780/remove-duplicate-lines-while-keeping-the-order-of-the-lines
## Without awk:
# cat -n out.txt | sort -k2 -k1n  | uniq -f1 | sort -nk1,1 | cut -f2-
## With perl:
# perl -ne 'print if ++$k{$_}==1' out.txt

## My original method.
## Doesn't remove empty lines, a feature for keepduplicatelines's gap mode.

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
  elif ! [ "$LINE" = "$LAST" ]   # This is slower, but /bin/sh cannot handle [ ! here.  O_o
  then
    echo "$N $LINE"
    LAST="$LINE"
  fi
done |
# tee final |
sort -n -k 1 |
afterfirst " "
