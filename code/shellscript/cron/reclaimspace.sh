## TODO: Allow user to specify two thresholds: one to try to clear past, another at which to warn user.
## TODO: What about prioritising which files are removed first?  What about allowing user to offer non-default reclaim directories?

# jsh-ext-depends: find
# jsh-depends-ignore: randomorder there flatdf
# jsh-depends: takecols drop error
## Rare danger of infinite loop if somehow rm -f repeatedly succeeds but does not reduce disk usage, or the number of files in RECLAIM/ .
## DONE: so that reclaimspace may be run regularly from cron, put in a max loop threshold to catch that condition.
## OK but this doesn't deal with the case when rm blocks for unhealthy system reasons.  So my cron line for relcaimspace now has a findjob check.

## This didn't work when if test -f "$FILE" hadn't quotes on a spaced file.
# set -e

# export MINKBYTES=10240 ## 10Meg
[ "$MINKBYTES" ] || export MINKBYTES=51200 ## 50Meg

SELECTIONREGEXP="$1"

echo
date

## TODO: this verision doesn't recognise when there is low space but nothing to reclaim, because the find is empty the inner loop is never called

## TODO: determine whether mount is ro, and if so skip it.

## BUG: There is some situation whereby the -lt test complains: 100%: integer expression expected
##      Ah yes this is when a really long device (eg. a file) is used, and the numbers drop to the next line!
##      The solution would be to join each line containing no spaces to the next line.  Although this (in fact the script anyway) would have trouble if the filename/device contains spaces.
##      Dodgy hack factored out to flatdf.

## TODO: rather than a dependency on this dirty external flatdf,
##       we should re-run df for each device of interest,
##       and use tail -1 and a sed which doesn't mind missing initial filename
##       (cos it could be one before the last line) to get the usage numbers.

# flatdf 2>/dev/null | drop 1 |
# takecols 1 4 6 |
# grep -v "/cdr" |
# # pipeboth |
# while read DEVICE SPACE MNTPNT
# do

## Like flatdf but better - only works on one mountpoint at a time.
function spaceon () {
	MNTPNT="$1"
	SPACE=`
		df "$MNTPNT" |
		## This ensures that if the line overflowed (eg. because the device was a long filename), we drop the file line and get only the stats line:
		tail -n 1 |
		## This extracts the available space field, whether the file/device was dropped or not:
		sed 's+^[^ 	]*[ 	]*[^ 	]*[ 	]*[^ 	]*[ 	]*\([^ 	]*\).*+\1+'
	`
	echo "$SPACE"
}

mount | grep "^/dev" |

grep "$SELECTIONREGEXP" |

takecols 1 3 |

while read DEVICE MNTPNT
do

	# SPACE=`flatdf | grep "^$DEVICE[ 	]" | takecols 4`
	## TODO: the following method is duplicated below; should be migrated into flatdf.
	SPACE=`spaceon "$MNTPNT"` ## Like flatdf but better - only works on one mountpoint at a time.
	## But since we grep "^dev", we don't tend to get an overflowing field 1 anyway!
	# SPACE=`df "$MNTPNT" | takecols 4`

	echo "Doing $DEVICE $MNTPNT ($SPACE"k")"

	ATTEMPTSMADE=0

	# [ -d "$MNTPNT"/RECLAIM ] && cd "$MNTPNT"/RECLAIM && find . -type f | countlines

	## Moving this find outside of the conditional while has made it more efficient (without memo) when many files need reclaiming, but very inefficient when 0 files need reclaiming.
	## Ideally we wouldn't do this if we check before and space is ok.
	# if [ -d "$MNTPNT"/RECLAIM ] && [ "$SPACE" -lt "$MINKBYTES" ] && cd "$MNTPNT"/RECLAIM
	## I was using this mode for debug purposes:
	if [ -d "$MNTPNT"/RECLAIM ] && cd "$MNTPNT"/RECLAIM
	# if [ -d "$MNTPNT"/RECLAIM ] && cd "$MNTPNT"/RECLAIM && [ "$SPACE" -lt "$MINKBYTES" ]
	then

		## I had a lot of trouble if I broke out of the while loop, because the find was left dangling and still outputting (worse on Gentoo's bash).
		## I did try cat > /dev/null to cleanup the end of the stream, but if I had already passed, the cat caused everything to block!
		## So I decided it's easier (especially if the script might be modified in the future), that the while loop should ready all of find's output,
		## but only act if low space requires it.
		# nice -n 20 find . -type f |
		# ( randomorder && echo ) | ## need this end line otherwise read FILE on last entry ends the stream and hence the sh is killed.
		# ( nice -n 20 find . -type f ; echo ; echo ; echo ) |
		## After huge changes it turns out it was only the 20 that was the problem on Gentoo; 10 seems ok.
		nice -n 10 find . -type f |

		# ( ## This sub-clause is needed so that the cat can send the rest of the randomorder stream somwhere, other bash under gentoo complains about a "Broken pipe"

			## I can't get set -e to work on these tests; because they are in while loop?  Ah they do now I've reduced the ()s.
			while read FILE
			do

				if [ "$SPACE" -lt "$MINKBYTES" ]
				then

					## Never reached if there was no more stream to read files from:
					# export DEBUG=true
					debug "$FILE"

					ATTEMPTSMADE=`expr "$ATTEMPTSMADE" + 1`
					if [ "$ATTEMPTSMADE" -gt 999 ]
					then
						## BUG: of course this can be reached legitimately before the work is done if the reclaim dir is full of many small or empty files.
						error "Stopping on \"timeout\" reclamation attempt # $ATTEMPTSMADE."
						## TODO: should we really timeout all?  Wouldn't it be better to timeout this partition, but proceed to rest?
						exit 12
					fi

					echo "Partition $DEVICE mounted at $MNTPNT has $SPACE"k" < $MINKBYTES"k" of space."

					REMOVED=
					if [ -f "$MNTPNT"/RECLAIM/"$FILE" ]
					then
						echo "Reclaiming: rm -f $MNTPNT"/RECLAIM/"$FILE"
						## Now we need to turn set -e off!
						# set +e
						if rm -f "$MNTPNT"/RECLAIM/"$FILE"
						then
							REMOVED=true
							DIR=`dirname "$MNTPNT"/RECLAIM/"$FILE"`
							rmdir -p "$DIR" 2>/dev/null
						fi
						# set -e
					fi

					# SPACE=`flatdf | grep "^$DEVICE[ 	]" | takecols 4`
					SPACE=`spaceon "$MNTPNT"` ## Like flatdf but better - only works on one mountpoint at a time.
					# echo "Now space is: $SPACE"

					if [ ! "$REMOVED" ]
					then
						## Actually this doesn't get run if the partition has no files to reclaim.  I believe the read FILE above causes a breakout when it tries to read past end of stream.
						echo "But I failed to reclaim: $FILE"
						## When two reclaimspace's are running, the reclamation of $FILE
						## by the other will cause this one to skip the partition.
						## No problem; two shouldn't really be running simultaneously anyway.
					fi

				# else echo "Skipping $FILE because $SPACE"k
				fi

			done

			## Recently(?) problems developed with this approach.  What if the last read reached end-of-stream?  Then cat probably blocks!
			## Failed attempt solving with the echo above, so that loop will break out before reading EOS so we can read it here.
			# cat > /dev/null
			## So now we do it inside the loop.

			echo " done $DEVICE $MNTPNT ($SPACE"k")"

		# )

	fi

done
