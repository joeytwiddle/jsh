DIR=`realpath "$1"`

FOUND=`

df | drop 1 | takecols 6 | sort |

while read MOUNTPNT
do

  if echo "$DIR" | grep "^$MOUNTPNT" > /dev/null
  then echo "$MOUNTPNT"
  fi

done |

tail -1

`

test "$FOUND" &&
echo "$FOUND" ||
error "Didn't find anything!"
