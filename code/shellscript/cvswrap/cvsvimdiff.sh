# Lets you do a diff against a file in CVS with
# vimdiff instead of diff.

FILENAME="$1"
REV="$2"
REV2="$3"

# if test "$FILENAME" = "" || test "$REV" = ""; then
if test "$FILENAME" = ""; then
	echo "cvsvimdiff <filename> [ <revision#> [ <another_revision#> ] ]"
	echo "  will check out a temporary revision(s) of <filename> and do a vimdiff..."
	echo "  at present, no <revision#> means compare against the most recent repository version."
	echo "  You may optionally set \$DIFFCOM to use a different diff program."
	echo "cvsvimdiff -all"
	echo "  Will vimdiff all uncommitted files, and commit those you :w (:qa) (uses cvsdiff)."
	echo "  (Hence DIFFCOM must not bg itself.)"
	exit 1
fi

if test "$FILENAME" = "-all"
then
	STARTTIME=`jgettmp cvsvimdiff-watchchange`
	ORIGFILETIME=`jgettmp cvsvimdiff-watchchange`
	touch "$STARTTIME"
	FILES=`cvsdiff |
	# drop 2 | chop 1 |
	grep -v "^$" | grep -v "^#" |
	sed 's/[ ]*#.*//'`
	## Doesn't handle spaces
	## But with previous while read vim complained input not from term (outside X)
	for FILE in $FILES
	do
		touch -r "$FILE" "$ORIGFILETIME"
		cvsvimdiff "$FILE" # doesn't work sometimes: > /dev/null 2>&1
		echo
		if newer "$FILE" "$STARTTIME"
		then
			echo "Committing $FILE"
			## Reset file's time to that which it had before cvsvimdiff
			touch -r "$ORIGFILETIME" "$FILE"
			cvscommit -m "" "$FILE"
		else
			echo "Not committing $FILE"
		fi
		echo
	done
	jdeltmp $STARTTIME $ORIGFILETIME
	exit 0
fi

# WHICHREV="Working"
WHICHREV="Repository"
if test "$REV" = ""; then
	REV=`cvs status "$FILENAME" |
			grep "$WHICHREV revision:" |
			after "$WHICHREV revision:" |
			tr "\t" " " | sed 's/^\( \)//g' |
			getnumber`
			# Note the sed tab does not work on Unix, hence tr
	echo "Diffing local against current $WHICHREV revision $REV"
fi

# Check out the specific revision requested
CKOUT=`jgettmp "$FILENAME-ver-$REV"`
cvs update -p -r "$REV" "$FILENAME" > "$CKOUT"

if test ! "$REV2" = ""; then
	CKOUT2=`jgettmp "$FILENAME-ver-$REV2"`
	# Check out the other revision requested
	cvs update -p -r "$REV2" "$FILENAME" > "$CKOUT2"
	# Adjust vars so that vimdiff runs on the two checked out files.
	FILENAME="$CKOUT"
	CKOUT="$CKOUT2"
fi

if test "$DIFFCOM" = ""; then
	DIFFCOM="vimdiff"
	# DIFFCOM="vimdiff -c"
	# DIFFCOMARG=":syn off
# :set wrap"
fi

$DIFFCOM "$FILENAME" "$CKOUT"
# $DIFFCOM "$DIFFCOMARG" "$FILENAME" "$CKOUT"
# -c ':syn off<Enter>:set wrap<Enter>'

# jdeltmp "$CKOUT"
# haven't handle'd second case, don't want to delete original file!!
