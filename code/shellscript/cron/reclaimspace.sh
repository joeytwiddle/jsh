## Rare danger of infinite loop if somehow rm -f repeatedly succeeds but does not reduce disk usage, or the number of files in RECLAIM/ .
## DONE: so that reclaimspace may be run regularly from cron, put in a max loop threshold to catch that condition.

## This didn't work when if test -f "$FILE" hadn't quotes on a spaced file.
set -e

# export MINKBYTES=10240 ## 10Meg
[ "$MINKBYTES" ] || export MINKBYTES=51200 ## 50Meg

## TODO: determine whether mount is ro, and if so skip it.

## BUG: There is some situation whereby the -lt test complains: 100%: integer expression expected
##      Ah yes this is when a really long device (eg. a file) is used, and the numbers drop to the next line!
##      The solution would be to join each line containing no spaces to the next line.  Although this (in fact the script anyway) would have trouble if the filename/device contains spaces.
##      Dodgy hack factored out to flatdf.

flatdf 2>/dev/null | drop 1 |

takecols 1 4 6 |
grep -v "/cdr" |

# pipeboth |

while read PARTITION SPACE POINT
do

	GOAGAIN=true
	ATTEMPTSMADE=0

	# [ -d "$POINT"/RECLAIM ] && cd "$POINT"/RECLAIM && find . -type f | countlines

	## Ideally we wouldn't do this if we check before and space is ok.
	[ -d "$POINT"/RECLAIM ] &&
	cd "$POINT"/RECLAIM &&
	find . -type f |
	( randomorder && echo ) | ## need this end line otherwise read FILE on last entry ends the stream and hence the sh is killed.

	## I can't get set -e to work on these tests; because they are in while loop?
	while [ "$SPACE" -lt "$MINKBYTES" ] && [ "$GOAGAIN" ]
	do

		ATTEMPTSMADE=`expr "$ATTEMPTSMADE" + 1`
		if [ "$ATTEMPTSMADE" -gt 999 ]
		then
			## BUG: of course this can be reached legitimately before the work is done if the reclaim dir is full of many small or empty files.
			error "Stopping on $ATTEMPTSMADE"st" reclamation attempt, assuming problem!"
			exit 12
		fi

		GOAGAIN=

		echo "Partition $PARTITION mounted at $POINT has $SPACE"k" < $MINKBYTES"k" of space."

		if [ -d "$POINT"/RECLAIM ]
		then

			read FILE
			# debug "$FILE"

			if [ -f "$POINT"/RECLAIM/"$FILE" ]
			then
				echo "Reclaiming: rm -f $POINT"/RECLAIM/"$FILE"
				rm -f "$POINT"/RECLAIM/"$FILE" &&
				GOAGAIN=true
			else
				echo "But there is nothing in $POINT/RECLAIM to reclaim.  $FILE"
			fi

		else

			echo "But there is no $POINT/RECLAIM directory to reclaim from."

		fi

		SPACE=`nicedf | grep "^$PARTITION" | takecols 4`

	done

done
