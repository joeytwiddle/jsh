## Like cksum but faster because only reads the start and end of each file
## Quick and useful for verification / indexing of written CDs

## TODO: would be nice for files <=32k to just to one dd and be done with
##       note that this would throw off any qkcksums people have made on small files
##       (it might be evident if only one md5sum produced)

# export LOGFILE=`jgettmp qkcsum.log`
# export BADFILE=`jgettmp qkcsum.bad`
export LOGFILE=/tmp/qkcksum.log
export BADFILE=/tmp/qkcksum.bad

for FILE
do
	BUFFSIZE=16384 ## 16k was 128k and was 1024b
	# if test -d "$FILE"; then continue; fi
	if test ! -f "$FILE"; then
		( curseyellow
		  echo "qkcksum: Skipping non-file \"$FILE\""
		  cursenorm ) >&2
		continue
	fi
	SIZE=`filesize "$FILE"`
	if test $SIZE -lt $BUFFSIZE; then BUFFSIZE=$SIZE; fi
	SEEK=`expr $SIZE - $BUFFSIZE`
	CKSUM=`
		(
			dd if="$FILE" bs=1 count=$BUFFSIZE 2> $LOGFILE &&
			dd if="$FILE" bs=1 count=$BUFFSIZE skip=$SEEK 2>> $LOGFILE ||
			(
				cursered; cursebold
				echo "Problem with $FILE"
				curseyellow
				cat "$LOGFILE"
				cursenorm
				touch $BADFILE
				echo "bad" >> "$LOGFILE"
			) >&2
		) | md5sum
	`
	if test -e $BADFILE
	then rm -f $BADFILE
	else echo "$CKSUM $SIZE $FILE"
	fi
done

# jdeltmp "$LOGFILE" "$BADFILE"
rm -f "$LOGFILE" "$BADFILE"
