## Pass -f to mkisofs to follow symlinks

## Hwi Debian:
# scanbus line:         0,0,0     0) 'ATAPI   ' 'CD-RW CW5201    ' '190C' Removable CD-ROM
DEVICE="0,0,0"
CDMNTPNT=/mnt/cdrw

## Hwi Gentoo:
# DEVICE="ATAPI:/dev/ide/host0/bus1/target1/lun0/cd"
# CDMNTPNT=/mnt/cdrom

## INCOMING: /usr/bin/cdrecord -v gracetime=2 dev=ATAPI:/dev/ide/host0/bus1/target1/lun0/cd speed=4 -dao -dummy driveropts=burnfree -eject -data -tsize=357971s -
## Oh and:   /usr/bin/mkisofs -gui -graft-points -volid HHG1of2 -volset  -appid K3B THE CD KREATOR VERSION 0.11.12 (C) 2003 SEBASTIAN TRUEG AND THE K3B TEAM -publisher  -preparer K3b - Version 0.11.12 -sysid LINUX -volset-size 1 -volset-seqno 1 -sort /tmp/kde-joey/k3bHvuBrc.tmp -rational-rock -hide-list /tmp/kde-joey/k3bbyYHec.tmp -full-iso9660-filenames -iso-level 2 -path-list /tmp/kde-joey/k3bPgqNfa.tmp
## from k3b

if test "$1" = "-multi"
then
	shift
	MULTICDRECORD="-multi -nofix -data"
	MULTIMKISOFS="-M $DEVICE"
	NEXT_TRACK=`cdrecord -msinfo dev="$DEVICE" 2>/dev/null`
	if test "$NEXT_TRACK" = ""
	then echo "Looks like a new disk to me."
	else MULTIMKISOFS="$MULTIMKISOFS -C $NEXT_TRACK"
	fi
	echo "Using mkisofs options: $MULTIMKISOFS"
	echo "Using cdrecord options: $MULTICDRECORD"
fi

CDRECORD_OPTS="minbuf=90"
## -eject
## -dummy 

## Removed inaccurate tsize=359232s (means 700, but did work!), may need to use mkisofs -print-size
cursegreen
echo "nice -n -20 mkisofs -r -J -jcharset default -f -l -D -L -V -P -p -abstract -biblio -copyright -graft-points /="$1" $MULTIMKISOFS |"
echo "nice -n -20 cdrecord $CDRECORD_OPTS dev=$DEVICE fs=31M -v speed=8 -pad $MULTICDRECORD -overburn -"
cursenorm
      nice -n -20 mkisofs -r -J -jcharset default -f -l -D -L -V -P -p -abstract -biblio -copyright -graft-points /="$1" $MULTIMKISOFS |
      nice -n -20 cdrecord $CDRECORD_OPTS dev=$DEVICE fs=31M -v speed=8 -pad $MULTICDRECORD -overburn -

## From HOWTO (does multi)
# mkisofs -R -o cd_image2 -C $NEXT_TRACK -M /dev/scd5 private_collection/

if test ! "$?" = 0
then exit 1
fi



### Post-write checksumming (to check it burnt OK, and to keep handy file index)

sleep 10
cursecyan

CDLDIR=/stuff/cdlistings

## Dunno why but my drive sometimes needs this as a sort of reset (it is done in parralel with directory checksum):
(
	eject $CDMNTPNT
	uneject $CDMNTPNT
) &

centralise "Checksumming directory"
if [ -f "$1" ]
then
	qkcksum "$@" |
	## Fixes mismatch checksum bug if user provided ./<file> as argument:
	sed 's+ ./+ +'
else
	cd "$1"
	$CDLDIR/findaz.sh
fi |
tee $CDLDIR/newcd.qkcksum.sb

wait ## For the eject, uneject above.

centralise "Checksumming cdrw"
mount $CDMNTPNT
cd $CDMNTPNT
$CDLDIR/findaz.sh | tee $CDLDIR/newcd.qkcksum
## Not needed; fix above was needed instead:
# $CDLDIR/findaz.sh | sed 's+ ./+ +' | tee $CDLDIR/newcd.qkcksum
# find . -type f | sed 's+^\./++' | foreachdo cksum | tee $CDLDIR/newcd.cksum

centralise "Comparing cksums"
jfcsh -bothways $CDLDIR/newcd.qkcksum.sb $CDLDIR/newcd.qkcksum

echo
if cmp $CDLDIR/newcd.qkcksum.sb $CDLDIR/newcd.qkcksum
then
  echo "CD written OK."
  echo
  exit 0
else
  echo "Oh dear: $CDLDIR/newcd.qkcksum.sb and $CDLDIR/newcd.qkcksum do not appear to match."
  echo "CD FAILED WRITE!"
  echo
  exit 1
fi
