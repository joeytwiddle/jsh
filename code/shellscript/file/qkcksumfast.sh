## Like cksum but faster because only reads the start and end of each file
## Quick and useful for verification / indexing of written CDs

for FILE
do
	echo ">>$FILE<<"
	BUFFSIZE=16384 ## 16k was 128k and was 1024b
	# if test -d "$FILE"; then continue; fi
	if test ! -f "$FILE"; then
		( curseyellow; echo "qkcksumfast: Skipping non-file \"$FILE\""; cursenorm ) >&2
		continue
	fi
	SIZE=`filesize "$FILE"`
	if test "$SIZE" -lt "$BUFFSIZE"; then BUFFSIZE="$SIZE"; fi
	SEEK=`expr $SIZE - $BUFFSIZE`
	CKSUM=`
		(
			dd if="$FILE" bs=1 count=$BUFFSIZE 2>/dev/null &&
			dd if="$FILE" bs=1 count=$BUFFSIZE skip=$SEEK 2>/dev/null ||
			( cursered; cursebold; echo "Problem with $FILE"; cursenorm ) >&2
		) | md5sum
	`
	echo "$CKSUM $SIZE $FILE"
done
