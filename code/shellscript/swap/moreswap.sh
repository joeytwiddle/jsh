#!/usr/bin/env bash

## This script finds the partition with the largest available space,
## and will try to create and use a swapfile there at half the available space sizes,
## or in case of failure, will proceed to the next partitions with availabe space.

## Done: if a previously created swapfile is there but NOT USED, then swapon it, and if successful, don't create a new swapfile.
## TODO: But it will only encounter it if it's on the partition with the most available space!  Ideally we'd do a search for existing unused swapfiles first.

#if ! [ "$UID" = 0 ]
#then echo "This script should be run as root"; exit 1
#fi

if ! [ "$UID" = 0 ]
then sudo moreswap "$@" ; exit
fi

## TODO: We should scan all partitions first for existing unused swapfiles, and only proceed to creation if none were found.

### List all partitions, but only consider those which are direct device mounts (avoid bound mounts and shm)
df | drop 1 | grep '^/dev/' | grep -E -v '/home/.*/mnt(/|$)' |
### Only consider root partition
#df / | drop 1 |
### Extract device available_kb, and mntpnt
takecols 1 4 6 | sort -r -n -k 2 |

# pipeboth |

while IFS=" 	" read -r DEVICE FREE_KB MNTPNT
do

	#echo "$DEVICE $FREE_KB $MNTPNT"

	if ! [ -w "$MNTPNT" ]
	then
		echo "Skipping $MNTPNT because it's not writable"
		continue
	fi

	if mount | grep "^${DEVICE}[ 	]" | grep -E " type (btrfs|xfs) " >/dev/null 2>&1
	then
		echo "Skipping $DEVICE due to fstype"
		continue
	fi

	SUCCESS=

	for N in $(seq 1 999)
	do
		SWAPFILE="$MNTPNT/swapfile${N}"

		if [ -e "$SWAPFILE" ]
		then
			if cat /proc/swaps | takecols 1 | grep -Fx "$SWAPFILE" >/dev/null
			then : ## Skipping already mounted swapfile
			else
				echo "Trying to make use of old unused swapfile ${SWAPFILE} size $(filesize "$SWAPFILE")"
				swapon "$SWAPFILE" &&
				SUCCESS=true &&
				break ## out of for loop
			fi

			## Proceed to next numbered swapfile (continue loop)
		else
			SWAPSIZE="$((FREE_KB / 1024 / 2))"
			## Don't exceed 512Meg
			[ "$SWAPSIZE" -gt 512 ] && SWAPSIZE=512

			echo "Making swapfile size $SWAPSIZE at ${SWAPFILE}"
			dd if=/dev/zero of="$SWAPFILE" bs=1MiB count="$SWAPSIZE" &&
			chmod 0600 "$SWAPFILE" &&
			mkswap "$SWAPFILE" &&
			swapon "$SWAPFILE" &&
			SUCCESS=true && ## since we can't break out of while from here

			break ## out of for loop
		fi
	done

	if [ -n "$SUCCESS" ]
	then
		echo "Success"
		break ## out of while loop
	fi

done

