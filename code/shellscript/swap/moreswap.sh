## This script finds the partition with the largest available space,
## and will try to create and use a swapfile there at half the available space sizes,
## or in case of failure, will proceed to the next partitions with availabe space.

## Done: if a previously created swapfile is there but NOT USED, then swapon it, and if successful, don't create a new swapfile.
## TODO: But it will only encounter it if it's on the partition with the most available space!  Ideally we'd do a search for existing unused swapfiles first.

## List partitions
df | drop 1 |
## Only consider those which are direct device mounts (avoid bound mounts and shm)
grep "^/dev/" |
## Extract device available_kb, and mntpnt
takecols 1 4 6 | sort -r -n -k 2 |

# pipeboth |

while read DEVICE FREE_KB MNTPNT
do

	if [ -w "$MNTPNT" ]
	then

		SUCCESS=

		for N in `seq -w 000 999`
		do

			SWAPFILE="$MNTPNT/moreswap.$N.swp"

			if [ -e "$SWAPFILE" ]
			then

				if cat /proc/swaps | grep "^$SWAPFILE[ 	]" > /dev/null
				then : ## Skipping already mounted swapfile
				else
					echo "Trying to make use of old unused swapfile $SWAPFILE size `filesize \"$SWAPFILE\"`"
					swapon "$SWAPFILE" &&
					SUCCESS=true &&
					break
				fi

				## Proceed to next numbered swapfile (continue loop)

			else

				## DONE: this badly needs to break the for loop
				## if dd succeeds but others do not!
				## Oh it does. =)
				## OK then: TODO: useful error reporting?
				SWAPSIZE=`expr "$FREE_KB" / 2`
				## Don't exceed 500Meg
				[ "$SWAPSIZE" -gt 500000 ] && SWAPSIZE=500000
				echo "Making swapfile size $SWAPSIZE at $SWAPFILE"
				dd if=/dev/zero of="$SWAPFILE" bs=1024 count=$SWAPSIZE &&
				mkswap "$SWAPFILE" &&
				swapon "$SWAPFILE" &&
				SUCCESS=true ## since we can't break out of while from here

				break ## out of for loop

			fi

		done

		if [ "$SUCCESS" ]
		then break ## out of while loop
		fi

	fi

done

