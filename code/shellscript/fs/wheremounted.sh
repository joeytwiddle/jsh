## See also: /bin/mountpoint -d (not available in morphix)
# jsh-ext-depends: sort realpath
# jsh-depends: takecols drop realpath
DIR=`realpath "$1"`

flatdf 2>/dev/null | drop 1 | takecols 6 |

sort |

while read MOUNTPNT
do

  if echo "$DIR" | grep "^$MOUNTPNT" > /dev/null
  then echo "$MOUNTPNT"
  fi

done |

tail -n 1
