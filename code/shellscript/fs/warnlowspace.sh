# jsh-depends: drop pipeboth takecols
if [ "$3" = "" ] || [ "$1" = --help ]
then
  echo
  echo "Usage: warnlowspace [ -v ] \"<email_address(es)>...\" <min_size_k> <device_pattern>s..."
  echo
  echo "  eg.: warnlowspace jim 10240 ^/dev/hd"
  echo "       will mail jim if any of his partitions has less than 10M of free space."
  echo
  echo "  Option -v displays matching devices on stderr, to check your pattern works ok."
  echo
  echo "  To send multiple emails, quote and separate with spaces: \"firstname@host secondname@host\""
  echo
  exit 1
fi

if [ "$1" = -v ]
then VERBOSE=true; shift
fi
EMAIL="$1"
MINSIZE="$2"
shift; shift

if [ ! "$HOST" ]
then HOST=`hostname`  ## TODO: not on Solaris!
fi

## Parse device patterns, and build (...|...) regexp for grep
DEVICES="\("
while [ "$1" ]
do
  DEVICES="$DEVICES$1"
  shift
  [ "$1" ] && DEVICES="$DEVICES\|"
done
DEVICES="$DEVICES\)"

## Get disk usage data
df | drop 1 | takecols 1 4 6 |

## Select only those matching pattern
grep "$DEVICES" |

if [ "$VERBOSE" ]
then pipeboth
else cat
fi |

while read DEVICE SPACE MNTPNT
do

  if [ "$SPACE" -lt "$MINSIZE" ]
  then

    [ "$VERBOSE" ] && echo "Sending warning: only $SPACE"k" on $DEVICE ($MNTPNT)"

    [ "$HOST" ] || HOST=`hostname`
    (
      echo "    WARNING from: $HOST"
      echo
      echo "   There is only: $SPACE"k" of space left (threshold $MINSIZE"k")"
      echo "       on device: $DEVICE"
      echo "  at mount point: $MNTPNT"
      echo
      echo "  [ Warning sent by script: warnlowspace, running as user #: $UID ]"
      ## TODO: it would be nice to du -sk $MNTPNT/*, but only on fs'es which can do it without grinding!
    ) |
    mail -s "[$HOST] Warning low space on $MNTPNT ($SPACE"k")" $EMAIL

  fi

done
