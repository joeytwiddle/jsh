WHERE="$1"
df -h |
if test ! "$WHERE"
then cat
else
  MOUNTPNT="`wheremounted \"$WHERE\"`"
  REALPATH=`realpath "$WHERE"`
	REST=`echo "$REALPATH" | afterfirst "$MOUNTPNT"`
  grep "$MOUNTPNT$" |
	sed "s+[ 	]$MOUNTPNT+ `cursegreen`$MOUNTPNT`cursenorm`$REST+g" |
  if [ -d "$MOUNTPNT/RECLAIM" ]
  then
		RECLAIMABLE=`dush "$MOUNTPNT/RECLAIM" | takecols 1`
		sed 's|\([	 ]*[[:digit:]]*%\)| + '"$RECLAIMABLE"'\1|'
	else
		cat
  fi
fi
