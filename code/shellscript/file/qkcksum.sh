# jsh-ext-depends: sed md5sum
# jsh-depends: cursebold cursered curseyellow cursenorm filesize md5sum

## Like cksum but faster because only reads the start and end of each file
## Quick and useful for verification / indexing of written CDs

## TODO: would be nice (more efficient) for files <=32k to just do one dd and be done with
##       note that this would throw off any qkcksums people have made on small files

# export LOGFILE=`jgettmp qkcsum.log`
# export BADFILE=`jgettmp qkcsum.bad`
export LOGFILE=/tmp/qkcksum.log
export BADFILE=/tmp/qkcksum.bad
## Prevents problems with multiple user write permissions, but could cause infloop if /tmp is non-writeable!
## TODO: Doesn't work: test -w <file> fails if file does not exist!
# while [ ! -w "$LOGFILE" ] || [ ! -w "$BADFILE" ]
# do
	# LOGFILE=$LOGFILE"_"
	# BADFILE=$BADFILE"_"
# done

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
	FILESIZE=`filesize "$FILE"`
	if test $FILESIZE -lt $BUFFSIZE; then BUFFSIZE=$FILESIZE; fi
	SEEK=`expr $FILESIZE - $BUFFSIZE`
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
		) |
		md5sum |
		## This avoids generating problematic lines like: "37167a8a1f30b436435b94c3ca8a6dbc  - 550 ./fixqkcksumerrors.sh" (which has an extra undesirable " -" field!)
		sed 's+  -$++'
	`
	if test -e $BADFILE
	then rm -f $BADFILE
	else echo "$CKSUM $FILESIZE $FILE"
	fi
done

# jdeltmp "$LOGFILE" "$BADFILE"
rm -f "$LOGFILE" "$BADFILE"
