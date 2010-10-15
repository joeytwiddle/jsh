#!/bin/sh
if [ "$1" = -f ]
then shift; FORCE=true
else echo "# Just displaying needed commands; rerun with -f or | sh to execute."
fi

CURRENT=`runlevel | after ' '`
DESIRED="$1"

CURRENTRC=/etc/rc$CURRENT.d
DESIREDRC=/etc/rc$DESIRED.d

for ACTION in stop start
do
	if [ $ACTION = start ]
	then
		FROM=$DESIREDRC
		TO=$CURRENTRC
	else
		FROM=$CURRENTRC
		TO=$DESIREDRC
	fi
	# echo diffcoms -diffwith jfcsh "ls $FROM" "ls $TO"
	diffcoms -diffwith jfcsh "ls $FROM" "ls $TO" |
	# pipeboth |
	# drop 6 |
	after [SKsk].. |
	while read SERVICE
	do
		echo /etc/init.d/"$SERVICE" $ACTION
		if [ "$FORCE" ]
		then /etc/init.d/"$SERVICE" $ACTION
		fi
	done
	echo
done

