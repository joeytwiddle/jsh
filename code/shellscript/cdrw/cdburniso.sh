#!/bin/sh
## driveropts=burnfree was suggested one time, but made no different on my drive

## Hwi Debian:
# scanbus line:         0,0,0     0) 'ATAPI   ' 'CD-RW CW5201    ' '190C' Removable CD-ROM
# CD_DEVICE="0,0,0"
## Hwi Gentoo: (scanbus gets nothing useful)
# CD_DEVICE="ATAPI:/dev/ide/host0/bus1/target1/lun0/cd"
[ "$CD_DEVICE" ] || CD_DEVICE="1001,0,0"

# SPEED=8
SPEED=12

if [ -f "$1" ]
then nice --20 cdrecord minbuf=90 dev="$CD_DEVICE" fs=90M -v speed=$SPEED -pad -overburn "$@"
fi
