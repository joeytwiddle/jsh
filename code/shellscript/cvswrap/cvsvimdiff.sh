# Lets you do a diff against a file in CVS with
# vimdiff instead of diff.

FILENAME="$1"
REV="$2"
REV2="$3"

# if test "$FILENAME" = "" || test "$REV" = ""; then
if test "$FILENAME" = ""; then
	echo "cvsvimdiff <filename> [ <revision#> [ <another_revision#> ] ]"
	echo "  will check out (a) temporary revision(s) of <filename> and do a vimdiff..."
	echo "  at present, no <revision#> means compare against the most recent repository version."
	exit 1
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

vimdiff "$FILENAME" "$CKOUT"

# jdeltmp "$CKOUT"
# haven't handle'd second case, don't want to delete original file!!
