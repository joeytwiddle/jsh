#!/bin/sh
# jsh-depends: drop pipeboth takecols
if [ "$2" = "" ] || [ "$1" = --help ]
then
  echo
  echo "warnlowspace [ -v ] \"<email_address(es)>...\" <min_size_k> [ <device_pattern>s... ]"
	echo
	echo "  sends a warning email if the free space on a drive falls below the threshold."
  echo
  echo "  eg.: warnlowspace jim 102400 \"^/dev/hd\""
  echo "       will mail jim if any of his partitions has less than 100M of free space."
	echo
	echo "  Each <device_pattern> is an extended regular expression."
	# echo "  Another example is: \"/dev/hd((a|b)[123456]|c(2|3))\""
	echo "  An example is: \"/dev/hd(a[124]|b[12])\""
	echo "  or: /dev/hda1 /dev/hda2 /dev/hda4 /dev/hdb1 /dev/hdb2"
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

## Parse device patterns, and build (...|...) regexp for grep -E
DEVICES="("
while [ "$1" ]
do
  DEVICES="$DEVICES$1"
  shift
  [ "$1" ] && DEVICES="$DEVICES|"
done
DEVICES="$DEVICES)"

## Get disk usage data
df | drop 1 | takecols 1 4 6 |
## Redirected stderr because hwibot repeats: df: `proc': No such file or directory
# df 2>/dev/null | drop 1 | takecols 1 4 6 |

## Select only those matching pattern
grep -E "$DEVICES" |

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
			[ "$USER" ] || USER=$UID
      echo "  [ Sent by \"warnlowspace\" running as $USER on $HOST at `date` ]"
      ## TODO: it would be nice to du -sk $MNTPNT/*, but only on fs'es which can do it without grinding!
			##       also, remember that unlike df, du -sk will not show space taken by files this user cannot read.
    ) |
    mail -s "[$HOST] Warning low space on $MNTPNT ($SPACE"k")" $EMAIL

  fi

done
