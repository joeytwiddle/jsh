## TODO: make this default, but also make it search beforehand, and warn if there are symlinks of big files already on the images, which would cause large duplicates.  Also run a df -L check.
## Pass -f to mkisofs to follow symlinks
## e.g.: MKISOFS_OPTS="-f" cdwritefiles <...>...

## Hwi Debian:
# scanbus line:         0,0,0     0) 'ATAPI   ' 'CD-RW CW5201    ' '190C' Removable CD-ROM
# DEVICE="0,0,0"
DEVICE="ATAPI:/dev/ide/host0/bus1/target0/lun0/cd" ## hwi's debian changed
CDMNTPNT=/mnt/cdrom

## Hwi Gentoo: (scanbus gets nothing useful)
# DEVICE="ATAPI:/dev/ide/host0/bus1/target1/lun0/cd"
# CDMNTPNT=/mnt/cdrom

SPEED=8
# SPEED=2
# SPEED=16
# SPEED=12

## INCOMING: /usr/bin/cdrecord -v gracetime=2 dev=ATAPI:/dev/ide/host0/bus1/target1/lun0/cd speed=4 -dao -dummy driveropts=burnfree -eject -data -tsize=357971s -
## Oh and:   /usr/bin/mkisofs -gui -graft-points -volid HHG1of2 -volset  -appid K3B THE CD KREATOR VERSION 0.11.12 (C) 2003 SEBASTIAN TRUEG AND THE K3B TEAM -publisher  -preparer K3b - Version 0.11.12 -sysid LINUX -volset-size 1 -volset-seqno 1 -sort /tmp/kde-joey/k3bHvuBrc.tmp -rational-rock -hide-list /tmp/kde-joey/k3bbyYHec.tmp -full-iso9660-filenames -iso-level 2 -path-list /tmp/kde-joey/k3bPgqNfa.tmp
## from k3b

if [ "$1" = "-multi" ]
then
	shift
	MULTICDRECORD="-multi -nofix -data"
	# MULTIMKISOFS="-M $DEVICE" ## TODO: -M should be used for multiple sessions, but NOT used to create multiple-media (audio then isofs data) track
	NEXT_TRACK=`cdrecord -msinfo dev="$DEVICE" 2>/dev/null`
	if test "$NEXT_TRACK" = ""
	then echo "Looks like a new disk to me."
	else MULTIMKISOFS="$MULTIMKISOFS -C $NEXT_TRACK"
	fi
	echo "Using mkisofs options: $MULTIMKISOFS"
	echo "Using cdrecord options: $MULTICDRECORD"
fi

TARGET="$1"

dush "$TARGET" || exit

[ "$MKISOFS" ] || MKISOFS=mkisofs

CDRECORD_OPTS="$CDRECORD_OPTS minbuf=90"
## -eject
[ "$DUMMY" ] && CDRECORD_OPTS="$CDRECORD_OPTS -dummy"
MKISOFS_OPTS="$MKISOFS_OPTS $MULTIMKISOFS"

# BUFFER_SIZE="32"
# BUFFER_SIZE="127M" ## I made it huge so I have lots of time to sort things out if I notice the fifo buffer is emptying
BUFFER_SIZE="96M" ## This is still huge; but not quite as long a delay for the buffer to fill :P

## Removed inaccurate tsize=359232s (means 700, but did work!), may need to use mkisofs -print-size
cursegreen
echo "nice -n -20 $MKISOFS $MKISOFS_OPTS -r -J -jcharset default -f -l -D -L -V -P -p -abstract -biblio -copyright -graft-points /="$TARGET" |"
echo "nice -n -20 cdrecord $CDRECORD_OPTS dev=$DEVICE fs=$BUFFER_SIZE -v speed=$SPEED -pad $MULTICDRECORD -overburn -"
cursenorm
      nice -n -20 $MKISOFS $MKISOFS_OPTS -r -J -jcharset default -f -l -D -L -V -P -p -abstract -biblio -copyright -graft-points /="$TARGET" |
      nice -n -20 cdrecord $CDRECORD_OPTS dev=$DEVICE fs=$BUFFER_SIZE -v speed=$SPEED -pad $MULTICDRECORD -overburn -

## From HOWTO (does multi)
# $MKISOFS -R -o cd_image2 -C $NEXT_TRACK -M /dev/scd5 private_collection/

if test ! "$?" = 0
then
	echo "There was an error; writing probably failed." >&2
	exit 1
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
if [ -f "$TARGET" ]
then
	qkcksum "$@" |
	## Fixes mismatch checksum bug if user provided ./<file> as argument:
	sed 's+ ./+ +'
else
	cd "$TARGET"
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

chown joey $CDLDIR/newcd.qkcksum $CDLDIR/newcd.qkcksum.sb

centralise "Comparing cksums"
jfcsh -bothways $CDLDIR/newcd.qkcksum.sb $CDLDIR/newcd.qkcksum

echo
if cmp $CDLDIR/newcd.qkcksum.sb $CDLDIR/newcd.qkcksum
then
  echo "`cursegreen`CD written OK.`cursenorm`"
  echo
  exit 0
else
  echo "Oh dear: $CDLDIR/newcd.qkcksum.sb and $CDLDIR/newcd.qkcksum do not appear to match."
  echo "CD FAILED WRITE!"
  echo
  exit 1
fi
