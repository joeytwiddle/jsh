DIR=`realpath "$1"`

df | drop 1 | takecols 6 | sort |

while read MOUNTPNT
do

  if echo "$DIR" | grep "^$MOUNTPNT" > /dev/null
  then echo "$MOUNTPNT"
  fi

done |

tail -1
