DIR=`realpath "$1"`

FOUND=""

df | drop 1 | takecols 6 | sort |

while read MOUNTPNT
do

  if echo "$DIR" | grep "^$MOUNTPNT" > /dev/null
  then FOUND="$MOUNTPNT"
  fi

done

test "$FOUND" &&
echo "$FOUND" ||
error "Didn't find anything!"
