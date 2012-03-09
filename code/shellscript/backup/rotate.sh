#!/bin/bash
# jsh-ext-depends-ignore: savelog file
# jsh-ext-depends: gzip tar cmp
# jsh-depends: del
# jsh-depends-ignore: after before

## TODO CONSIDER: Never overwrite the .0 backup?

## TODO: allow one environment variable which determines whether number comes after extension or before it
## TODO: allow another which determines whether a number, or a geekdate is used (and how fine it needs to be)

## TODO: inconsistency: rotating a file removes it, but rotating a folder leaves it intact!
## NOTE: beware that some of my scripts to rotate logs and mailboxes require that the file is either emptied or removed.  Note that printf "" > might be better than rm, because anything writing to the file might still get some done!

## TODO: For the case when some program is writing to the file and does not let go whilst we are rolling it:
##       Instead of moving file / inode (bad), I think we should printf "" > "$FILE" to ensure it is emptied, and to ensure the software continues to write to the live file.
##       (We can cp or cat | gzip the file to create the newest rotated.)

## TODO: What's that oldMEGA business?  Is it kosha?
## TODO: Instead of moving, or deleting, original file, sometimes it may be better to echo -n into it.  (inode business)
## TODO: auto -nozip for all zip files!  (or files which compress badly, ie. compressed in any way, eg. au, vid)

## Wait a minute: is this used for backups, or for overlarge rolling logs?
## TODO: don't create another file if its a duplicate of the last

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo "rotate [ -keep ] [ -nozip ] [ -max <num> ] [ -nodups ] <file/dir>*"
	### TODO!
	echo "  TODO: the default should be to have all these options ON!"
	echo "  will compress each <file> to <file>.gz.N, and make <file> empty."
	echo "  or compress each <dir> to <dir>.tgz.N, leaving it untouched."
	echo "  -keep:  will not empty the file after rotation (via tmpfile <file>.keep)"
	echo "  -nozip: will not gzip or tar-up the file or directory before rotation"
	echo "  -max:   will rotate to ensure no more than <num> + 1 logs (default=infinity)"
	echo "  never rotates <file>[.gz].0"
	echo
	echo "  Actually if the zip method is asked to work on a folder, it leaves the original folder intact, regardless of -keep!"
	echo
	echo "You may also wish to investigate savelog(8), part of debianutils."
	echo "jsh rotate appears to do the opposite of lograte.  Higher numbers are more recent here."
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

function logfriendly_gzip () {
	## TODO: this isn't as atomic as it should be; maybe there is a better way
		OUTPUT_FILE="$1"
		INPUT_FILE="$2"
		cat "$INPUT_FILE" | gzip -c > "$OUTPUT_FILE" &
		sleep 5 ## give cat time to get a handle on the file (generous in case system is busy)
		printf "" > "$FILE" ## clear the file asap, so that new additions made during the gzip are in a new file
		wait
}

for FILE
do

	if [ "$KEEP" ]
	then cp -a "$FILE" "$FILE.keep"
	fi

	## What extension will we use, if any?
	if [ ! "$ZIP" ]
	then EXT=""
	elif [ -f "$FILE" ]
	then EXT=.gz
	elif [ -d "$FILE" ]
	then EXT=.tgz
	else
		jshwarn "$FILE is not a file or directory; I don't know what to do!"
		exit 1
	fi

	## What will new file be called (what number)?
	## TODO: user can optionally choose to append the date (date+time?) to the file instead
	N=0
	FINALFILE="$FILE.$N$EXT"
	while [ -f "$FINALFILE" ]
	do
		LASTFINAL="$FINALFILE"
		N=`expr "$N" + 1`
		FINALFILE="$FILE.$N$EXT"
		# [ "$MAX" ] && [ "$N" -gt "$MAX" ] && jshwarn "Exceeded max $MAX with $FINALFILE and haven't yet fixed code to deal with this."
	done

	while [ "$MAX" ] && [ "$N" -gt "$MAX" ]
	do
		jshinfo "$N exceeds max $MAX, so rotating earlier copies..."
		for OLDN in `seq 1 $((N-2))`
		do
			NEWN=$((OLDN+1))
			# if shexec cmp "$FILE.$NEWN$EXT" "$FILE.$OLDNEXT" ## could make this optional on [ "$SKIPNEXT" ] || but then SKIPNEXT would be set ="" anyway :P  this is inefficient but seems tidier
			if cmp "$FILE.$NEWN$EXT" "$FILE.$OLDN$EXT" >/dev/null ## could make this optional on [ "$SKIPNEXT" ] || but then SKIPNEXT would be set ="" anyway :P  this is inefficient but seems tidier
			then
				SKIPNEXT=true
				jshwarn "$NEWN$EXT = $OLDN$EXT so SKIPNEXT=true" #  verbosely mv -f \"$FILE.$NEWN$EXT\" \"$FILE.$OLDN$EXT\"" ||
			else
				SKIPNEXT=
			fi
			[ "$SKIPNEXT" ] &&
			verbosely mv -f "$FILE.$NEWN$EXT" "$FILE.$OLDN$EXT"
		done
		N=$((N-1))
		FINALFILE="$FILE.$N$EXT"
	done

	DOZIPCOM=""
	## How will we compress it?
	if [ ! "$ZIP" ]
	then
		## TODO: does this work if it's a dir, and is it logfriendly?
		DOZIPCOM="move file"
		function zipcom() {
			mv "$FILE" "$FINALFILE"
		}
	elif [ -f "$FILE" ]
	then
		DOZIPCOM="logfriendly_gzip"
		function zipcom() {
			logfriendly_gzip "$FINALFILE" "$FILE"
		}
	elif [ -d "$FILE" ]
	then
		DOZIPCOM="gzipped-tarball"
		function zipcom() {
			tar cfz "$FINALFILE" "$FILE"
		}
		## BUG TODO: even without -keep, this will leave the $FILE (directory) intact =/
	else
		echo "$FILE is not a file or a directory"
		exit 1
	fi

	## Do the compression, if needed:
	if [ "$DOZIPCOM" ]
	then
		# echo "rotate: $ZIPCOM \"$FILE\""
		# echo "rotate: $ZIPCOM"
		# echo "Rotating $FILE to $FINALFILE with `declare -f zipcom | tr '\n\t' '  '`"
		echo "Rotating $FILE to $FINALFILE with $DOZIPCOM"
		oldSize=`filesize "$FILE"`
		zipcom || exit 1
		newSize=`filesize "$FINALFILE"`
		echo "Size changed from $oldSize to $newSize"
	fi

	## If we wanted to keep the original file, but gzip has removed it:
	if [ "$KEEP" ]
	then mv "$FILE.keep" "$FILE"
	fi

	## If avoiding duplicates, check whether we have already backed up an identical copy of this file/directory:
	if [ "$NODUPS" ] && [ "$LASTFINAL" ] && cmp "$FINALFILE" "$LASTFINAL"
	then
		echo "rotate: skipping backup because files is identical to last"
		del "$FINALFILE"
		## To skip processing of latter section
		# MAX=
		N=$LASTN
	else
		# echo "rotate: mv \"$FINALFILE\" \"$FINALFILE.$N\""
		# mv "$FINALFILE" "$FINALFILE.$N"
		## Now we do nothing, because FINALFILE should have been worked out already
		:
	fi

	## If we exceed the maximum, then do the rotation:
	## TODO: This has been disabled for now; it needs to be refactored to deal with the new style
	##       Fortunately at present, no important jsh scripts use -max.
	# if [ "$MAX" ]
	# then
		# if [ "$N" -gt "$MAX" ]
		# then
			# echo "Rotating the files..."
			# ## Start at 1 so 0 is not rotated.
			# X=1
			# # mv "$FINALFILE.$X" "$FINALFILE.$X.oldMEGAbakB4rotate" ## ???!
			# while [ "$X" -lt "$N" ]
			# do
				# XN=`expr "$X" + 1`
				# verbosely mv "$FINALFILE.$XN" "$FINALFILE.$X"
				# X="$XN"
			# done
		# fi
	# fi

done

