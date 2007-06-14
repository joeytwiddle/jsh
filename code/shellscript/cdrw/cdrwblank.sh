## blank a full cd quickly:
TYPE=fast
SPEED=8
if [ "$1" = -full ]
then
	TYPE=all
	SPEED=8 ## still goes at speed 4 :( and takes 21 minutes!
fi

# DEVICE="0,0,0"
DEVICE="ATAPI:/dev/ide/host0/bus1/target0/lun0/cd" ## hwi's debian changed

cdrecord dev="$DEVICE" gracetime=2 -v speed=$SPEED blank=$TYPE &&
true
# eject /mnt/cdrw &&
# uneject /mnt/cdrw
