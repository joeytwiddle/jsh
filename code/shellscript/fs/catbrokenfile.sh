#!/bin/sh
# BLOCKSIZE=$((10*1024*1024)) ## 10 meg
BLOCKSIZE=$((30*1024*1024)) ## 30 meg

DDLOGFILE=/tmp/catbrokenfile.dd."$$"

for FILENAME
do

	END=`filesize "$FILENAME"`

	for OFFSET in `intseq 0 "$BLOCKSIZE" "$END"`
	do

		jshinfo "`geekdate -fine` $OFFSET / $END"
		BLOCKS_TO_SKIP=$((OFFSET/BLOCKSIZE))

		# dd if="$FILENAME" bs="$BLOCKSIZE" skip="$BLOCKS_TO_SKIP" count=1 2>"$DDLOGFILE"
		## Trying putting it in a shell, to see if it's easier to kill it when it blocks, by killing the sh (probably won't work):
		# sh -c "dd if=\"$FILENAME\" bs=\"$BLOCKSIZE\" skip=\"$BLOCKS_TO_SKIP\" count=1" 2>"$DDLOGFILE"
		## Less efficient, but might make it easier to kill dd:
		# sh -c "dd if=\"$FILENAME\" bs=1 skip=\"$OFFSET\" count=\"$BLOCKSIZE\"" 2>"$DDLOGFILE"
		## This version, transferring 4096 bytes at a time, was not too slow on good blocks, and unblocked reasonably quickly from failures :)
		BITSIZE=$((1024*4))
		NUMBITS=$((BLOCKSIZE/BITSIZE))
		BITSTOSKIP=$((BLOCKS_TO_SKIP*NUMBITS))
		sh -c "dd if=\"$FILENAME\" bs=$BITSIZE skip=\"$BITSTOSKIP\" count=\"$NUMBITS\"" 2>"$DDLOGFILE"

		jshinfo "`cat "$DDLOGFILE" | tail -n 1`"

		## Check to see if the correct number of bytes were sent:
		## BUG TODO: This reports a failure on the last block!
		BYTES_TRANSFERRED=`tail -n 1 "$DDLOGFILE" | beforefirst " bytes "`
		if [ ! "$BYTES_TRANSFERRED" = "$BLOCKSIZE" ]
		then
			jshwarn "Failure on block $BLOCKS_TO_SKIP: only copied $BYTES_TRANSFERRED bytes"
			## If not, make up the difference with blank data:
			[ "$BYTES_TRANSFERRED" ] || BYTES_TRANSFERRED=0 ## If it was manually killed, dd may not output as usual.
			DIFFERENCE=$((BLOCKSIZE-BYTES_TRANSFERRED))
			# dd if=/dev/zero bs=1 count="$DIFFERENCE" 2>/dev/null
			dd if=/dev/zero count=1 bs="$DIFFERENCE" 2>/dev/null
		fi

	done

done

del "$DDLOGFILE" >/dev/null 2>&1
