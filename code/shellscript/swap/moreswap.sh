## This script finds the partition with the largest available space,
## and will try to create and use a swapfile there at half the available space sizes,
## or in case of failure, will proceed to the next partitions with availabe space.

## Done: if a previously created swapfile is there but NOT USED, then swapon it, and if successful, don't create a new swapfile.
## TODO: But it will only encounter it if it's on the partition with the most available space!  Ideally we'd do a search for existing unused swapfiles first.

#if ! [ "$UID" = 0 ]
#then echo "This script should be run as root"; exit 1
#fi

if ! [ "$UID" = 0 ]
then sudo moreswap "$@"
fi

### List all partitions, but only consider those which are direct device mounts (avoid bound mounts and shm)
#df | drop 1 | grep '^/dev/' |
### Only consider root partition
df / | drop 1 |
### Extract device available_kb, and mntpnt
takecols 1 4 6 | sort -r -n -k 2 |

# pipeboth |

while read DEVICE FREE_KB MNTPNT
do

	if [ -w "$MNTPNT" ]
	then

		SUCCESS=

		for N in `seq 1 999`
		do

			SWAPFILE="$MNTPNT/swapfile${N}"

			if [ -e "$SWAPFILE" ]
			then

				if cat /proc/swaps | takecols 1 | grep -Fx "$SWAPFILE" >/dev/null
				then : ## Skipping already mounted swapfile
				else
					echo "Trying to make use of old unused swapfile $SWAPFILE size `filesize \"$SWAPFILE\"`"
					swapon "$SWAPFILE" &&
					SUCCESS=true &&
					break
				fi

				## Proceed to next numbered swapfile (continue loop)

			else

				SWAPSIZE=`expr "$FREE_KB" / 1024 / 2`
				## Don't exceed 500Meg
				[ "$SWAPSIZE" -gt 500 ] && SWAPSIZE=500
				echo "Making swapfile size $SWAPSIZE at $SWAPFILE"
				dd if=/dev/zero of="$SWAPFILE" bs=1MiB count=$SWAPSIZE &&
				chmod 0600 "$SWAPFILE" &&
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

