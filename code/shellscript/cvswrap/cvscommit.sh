getfiles () {
	cvsdiff "$@" |
	# drop 2 | chop 1 |
	grep -v "^$" | grep -v "^#" |
	sed 's/[ ]*#.*//'
}

export COLUMNS

if test "$1" = "-diff"
then

	shift
	FILES=`getfiles "$@"`
	TMPFILE=`jgettmp "repository_version"`
	for FILE in $FILES
	do
		if test ! -f "$FILE"
		then error "skipping non-file: $FILE"; continue
		fi
		(
			cvs status "$FILE"
			# cvs diff "$FILE"
			cvs -q update -p "$FILE" > $TMPFILE
			# jdiff "$TMPFILE" $FILE
		# )
			jdiff -infg "$TMPFILE" $FILE
		) | more
		curseyellow
		echo
		echo "Provide a comment with which to commit $FILE, or <Enter> to skip.  ('.<Enter>' will commit empty comment.)"
		cursenorm
		read INPUT
		if test "$INPUT"
		then
			test "$INPUT" = "." && INPUT=""
			cursegreen
			echo "Committing with comment: $INPUT"
			cursecyan
			echo "cvscommit -m \"$INPUT\" \"$FILE\""
			cursenorm
			cvscommit -m "$INPUT" "$FILE"
		fi
		echo
	done
	jdeltmp $TMPFILE

elif test "$1" = "-vimdiff"
then

	shift
	FILES=`getfiles "$@"`
	STARTTIME=`jgettmp cvsvimdiff-watchchange`
	ORIGFILETIME=`jgettmp cvsvimdiff-watchchange`
	touch "$STARTTIME"
	## Doesn't handle spaces
	## But with previous while read vim complained input not from term (outside X)
	## Now we are sometimes getting cvs errors in the filelist.
	for FILE in $FILES
	do
		echo
		if test ! -f "$FILE"
		then error "skipping non-file: $FILE"; continue
		fi
		touch -r "$FILE" "$ORIGFILETIME"
		if ! cvsvimdiff "$FILE" # doesn't work sometimes: > /dev/null 2>&1
		then
			echo
			error "cvsvimdiff exited badly"; continue
		fi
		echo
		if newer "$FILE" "$STARTTIME"
		then
			cursegreen; cursebold
			echo "Committing $FILE"
			cursenorm
			echo
			## Reset file's time to that which it had before cvsvimdiff
			touch -r "$ORIGFILETIME" "$FILE"
			cvscommit -m "" "$FILE"
		else
			curseyellow
			echo "Not committing $FILE"
			cursenorm
		fi
	done
	jdeltmp $STARTTIME $ORIGFILETIME

else

	cvs -q commit "$@"
	# | grep -v "^? "
	## caused: "Vim: Warning: Output is not to a terminal"
	cvsedit "$@" 2> /dev/null

fi
