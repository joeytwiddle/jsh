if [ "$1" = -rcs ]
then RCS=true; shift
fi

for FNAME
do

	# VERNUM=`
		# cvs status "$FNAME" |
		# grep "Repository revision:" |
		# takecols 3
	# `
# 
	# if [ ! "$VERNUM" ]
	# then
		# echo "Failed to get version number for: $FNAME" >&2
		# continue
	# fi

	if [ "$RCS" ]
	then rlog "$FNAME"
	else cvs log "$FNAME"
	fi |
	grep "^revision " |
	takecols 2 |

	while read VERNUM
	do

		## TODO: consider refusing to overwrite files
		if [ "$RCS" ]
		then
			echo "co -p\"$VERNUM\" \"$FNAME\" > \"$FNAME.$VERNUM\""
			co -p"$VERNUM" "$FNAME" > "$FNAME.$VERNUM"
		else
			echo "cvs update -r \"$VERNUM\" -p \"$FNAME\" > \"$FNAME.$VERNUM\""
			cvs update -r "$VERNUM" -p "$FNAME" > "$FNAME.$VERNUM"
		fi

	done
	
done

