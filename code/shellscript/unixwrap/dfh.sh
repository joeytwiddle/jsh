WHERE="$1"
df -h |
if test ! "$WHERE"
then cat
else
  realpath "$WHERE"
  MOUNTPNT="`wheremounted \"$WHERE\"`"
  higrep "$MOUNTPNT"
  if test -d "$MOUNTPNT/RECLAIM"
  then dush "$MOUNTPNT/RECLAIM"
  fi
fi
