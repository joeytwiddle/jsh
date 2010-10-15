#!/bin/sh
## Blank a RW cd quickly or fully.

TYPE=fast
SPEED=8
if [ "$1" = -full ]
then
	TYPE=all
	SPEED=8 ## still goes at speed 4 :( and takes 21 minutes!
fi

# [ "$CD_DEVICE" ] || CD_DEVICE="0,0,0"
# [ "$CD_DEVICE" ] || CD_DEVICE="ATAPI:/dev/ide/host0/bus1/target0/lun0/cd" ## hwi's debian changed
# [ "$CD_DEVICE" ] || CD_DEVICE="/dev/hdc" ## gentoo
# [ "$CD_DEVICE" ] || CD_DEVICE="ATAPI:0,0,0" ## Result of -scanbus dev=ATAP - didn't work
# [ "$CD_DEVICE" ] || CD_DEVICE="1001,0,0" ## Result of -scanbus with no dev - worked!
[ "$CD_DEVICE" ] || CD_DEVICE="/dev/hdc"

cdrecord dev="$CD_DEVICE" gracetime=2 -v speed=$SPEED blank=$TYPE &&
true
# eject /mnt/cdrw &&
# uneject /mnt/cdrw


# The command line option 'dev=/dev/hdX' (X is the name of your drive)
# should be used for IDE CD writers.  And make sure that the permissions
# on this device are set properly and your user is in the correct group.

