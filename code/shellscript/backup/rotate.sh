## TODO: What's that oldMEGA business?  Is it kosha?
## TODO: Instead of moving, or deleting, original file, sometimes it may be better to echo -n into it.  (inode business)
## TODO: auto -nozip for all zip files!  (or files which compress badly, ie. compressed in any way, eg. au, vid)

## Wait a minute: is this used for backups, or for overlarge rolling logs?
## TODO: don't create another file if its a duplicate of the last

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "rotate [ -keep ] [ -nozip ] [ -max <num> ] [ -nodups ] <file>"
	echo "  will move <file> to <file>.N"
	echo "  -keep:  will retain the file after rotation (via tmpfile <file>.keep)"
	echo "  -nozip: will not gzip or tar-up the file or directory before rotation"
	echo "  -max:   will rotate to ensure no more than <num> + 1 logs"
	echo "  never rotates <file>[.gz].0"
	echo
	echo "You may also wish to investigate savelog(8), part of debianutils."
	exit 1
fi

KEEP=
if [ "$1" = -keep ]
then KEEP=true; shift
fi

ZIP=true
if [ "$1" = -nozip ]
then ZIP=; shift
fi

MAX=
if [ "$1" = -max ]
then shift; MAX="$1"; shift
fi

NODUPS=
if [ "$1" = -nodups ]
then NODUPS=true; shift
fi

for FILE
do

	if [ "$KEEP" ]
	then cp "$FILE" "$FILE.keep"
	fi

	if [ ! "$ZIP" ]
	then
		ZIPCOM=""
		FINALFILE="$FILE"
	elif [ -f "$FILE" ]
	then
		ZIPCOM="gzip"
		FINALFILE="$FILE.gz"
	elif [ -d "$FILE" ]
	then
		ZIPCOM="tar cfz $FILE.tgz"
		FINALFILE="$FILE.tgz"
	else
		echo "$FILE is not a file or a directory"
		exit 1
	fi

	if [ "$ZIPCOM" ]
	then
		echo "rotate: $ZIPCOM \"$FILE\""
		$ZIPCOM "$FILE" || exit 1
	fi

	N=0
	while [ -f "$FINALFILE.$N" ]
	do
		LASTN="$N"
		N=`expr "$N" + 1`
	done

	if [ "$NODUPS" ] && [ "$LASTN" ] && cmp "$FINALFILE" "$FINALFILE.$LASTN"
	then
		echo "rotate: skipping backup because files are identical"
		del "$FINALFILE"
		## To skip processing of latter section
		# MAX=
		N=$LASTN
	else
		echo "rotate: mv \"$FINALFILE\" \"$FINALFILE.$N\""
		mv "$FINALFILE" "$FINALFILE.$N"
	fi

	if [ "$KEEP" ]
	then mv "$FILE.keep" "$FILE"
	fi

	if [ "$MAX" ]
	then
		if [ "$N" -gt "$MAX" ]
		then
			echo "Rotating the files..."
			## Start at 1 so 0 is not rotated.
			X=1
			mv "$FINALFILE.$X" "$FINALFILE.$X.oldMEGAbakB4rotate"
			while test "$X" -lt "$N"
			do
				XN=`expr "$X" + 1`
				mv "$FINALFILE.$XN" "$FINALFILE.$X"
				X="$XN"
			done
		fi
	fi

done
