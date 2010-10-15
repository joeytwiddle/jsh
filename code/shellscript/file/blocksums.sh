#!/bin/sh
BLOCKSIZE=`expr 1024 '*' 1024 '*' 4`

BLOCKNUM=0

FILE="$1"

FILESIZE=`filesize "$FILE"`

NUMBLOCKS=`expr $FILESIZE / $BLOCKSIZE`

for BLOCKNUM in `seq -w 0 $NUMBLOCKS`
do

	BLOCKOFF=`expr $BLOCKNUM '*' $BLOCKSIZE`
	# echo -n "$BLOCKNUM "
	echo -n "$BLOCKOFF "
	dd if="$FILE" ibs=$BLOCKSIZE skip=$BLOCKNUM count=1 2>/dev/null |
	md5sum

done
