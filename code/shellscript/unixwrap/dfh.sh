if [ "$1" = --help ]
then

	echo "df [ <path>s ]"
	exit 1

elif [ ! "$*" ]
then

	flatdf -h

else

	for WHERE
	do
		MOUNTPNT="`wheremounted \"$WHERE\"`"
		REALPATH=`realpath "$WHERE"`
		REST=`echo "$REALPATH" | afterfirst "$MOUNTPNT"`
		flatdf -h |
		grep "$MOUNTPNT$" |
		sed "s|[ 	]$MOUNTPNT| $MOUNTPNT`cursegreen`$REST`cursenorm`|g" |
		if [ -d "$MOUNTPNT/RECLAIM" ]
		then
			RECLAIMABLE=`dush "$MOUNTPNT/RECLAIM" | takecols 1`
			sed 's|\([	 ]*[[:digit:]]*%\)| + '"$RECLAIMABLE"'\1|'
		else
			cat
		fi
	done

fi
