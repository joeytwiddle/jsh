#!/bin/sh
if [ "$1" = -rcs ]
then RCS=true; shift
fi

# BEFOREVER=
# BEFOREVER=-r
BEFOREVER=cvs.

for FNAME
do

	# REVISION=`
		# cvs status "$FNAME" |
		# grep "Repository revision:" |
		# takecols 3
	# `
# 
	# if [ ! "$REVISION" ]
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
	reverse |

	while read REVISION
	do

		## TODO: consider refusing to overwrite files
		if [ "$RCS" ]
		then verbosely co -p"$REVISION" "$FNAME" > "$FNAME.$BEFOREVER$REVISION"
		else verbosely cvs update -r "$REVISION" -p "$FNAME" > "$FNAME.$BEFOREVER$REVISION"
		fi
		sleep 1 ## slows it down but at least dates checkouts in order (although not by their real date)

	done
	
done

