## Rare danger of infinite loop if somehow rm -f repeatedly succeeds but does not reduce disk usage, or the number of files in RECLAIM/ .
## TODO: so that reclaimspace may be run regularly from cron, put in a max loop threshold to catch that condition.

## This didn't work when if test -f "$FILE" hadn't quotes on a spaced file.
set -e

df | drop 1 | takecols 1 4 6 |

while read PARTITION SPACE POINT
do

  GOAGAIN=true

  while test $SPACE -lt 10240 && test "$GOAGAIN"
  do

    GOAGAIN=

    echo "Partition $PARTITION mounted at $POINT has $SPACE"k" < 10M of space."

    if test -d "$POINT"/RECLAIM
    then

      FILE=`
        cd "$POINT"/RECLAIM &&
        find . -type f |
        chooserandomline
      `
      if test -f "$POINT"/RECLAIM/"$FILE"
      then
        echo "Reclaiming: $POINT"/RECLAIM/"$FILE"
        rm -f "$POINT"/RECLAIM/"$FILE" &&
        GOAGAIN=true
      fi

    fi

    if test ! "$GOAGAIN"
    then echo "But there was nothing in $POINT/RECLAIM to reclaim."
    fi

    SPACE=`df | grep "^$PARTITION" | takecols 4`

  done

done
