if test "$1" = "-vimdiff"
then
	shift
	STARTTIME=`jgettmp cvsvimdiff-watchchange`
	ORIGFILETIME=`jgettmp cvsvimdiff-watchchange`
	touch "$STARTTIME"
	FILES=`cvsdiff "$@" |
	# drop 2 | chop 1 |
	grep -v "^$" | grep -v "^#" |
	sed 's/[ ]*#.*//'`
	## Doesn't handle spaces
	## But with previous while read vim complained input not from term (outside X)
	for FILE in $FILES
	do
		if test ! -f "$FILE"
		then error "skipping non-file: $FILE"; continue
		fi
		touch -r "$FILE" "$ORIGFILETIME"
		cvsvimdiff "$FILE" # doesn't work sometimes: > /dev/null 2>&1
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
		echo
	done
	jdeltmp $STARTTIME $ORIGFILETIME
	exit 0
fi

cvs -q commit "$@"
# | grep -v "^? "
## caused: "Vim: Warning: Output is not to a terminal"
cvsedit "$@"
