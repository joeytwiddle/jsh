#!/bin/sh
## BUG: with really large integers, (gawk) can output funny representations, e.g.: 2.80336e+09
awk ' BEGIN { n = 0 } { n += $1 } ; END { print n } '

exit

## Shell version.  Should refactor name now!
## It broke: 1250879090+: syntax error: operand expected (error token is "+")
TOTAL=0
while read LINE
# do TOTAL=`expr "$TOTAL" + $LINE`
do TOTAL=$(($TOTAL+$LINE))
done
echo "$TOTAL"

## NOTE: if you ever have a version of sh which doesn't pass TOTAL back out of the while,
##       then try putting the echo "$TOTAL" inside the loop and | tail -n 1 after the done.
