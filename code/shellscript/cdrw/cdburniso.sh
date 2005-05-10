## driveropts=burnfree was suggested one time, but made no different on my drive

## Hwi Debian:
# scanbus line:         0,0,0     0) 'ATAPI   ' 'CD-RW CW5201    ' '190C' Removable CD-ROM
DEVICE="0,0,0"

## Hwi Gentoo: (scanbus gets nothing useful)
# DEVICE="ATAPI:/dev/ide/host0/bus1/target1/lun0/cd"

if [ -f "$1" ]
then nice --20 cat "$@" | nice --20 cdrecord minbuf=90 dev="$DEVICE" fs=31M -v speed=8 -pad -overburn -
fi
