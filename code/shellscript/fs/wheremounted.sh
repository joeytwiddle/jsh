DIR=`realpath "$1"`

FOUNDTMP=`jgettmp wheremounted`

df | drop 1 | takecols 6 | sort |

while read MOUNTPNT
do

  if echo "$DIR" | grep "^$MOUNTPNT" > /dev/null
  then echo "$MOUNTPNT" > "$FOUNDTMP"
  fi

done

FOUND=`cat "$FOUNDTMP"`

test "$FOUND" &&
echo "$FOUND" ||
error "Didn't find anything!"
