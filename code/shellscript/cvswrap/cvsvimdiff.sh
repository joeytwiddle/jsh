# Lets you do a diff against a file in CVS with
# vimdiff instead of diff.

FILENAME="$1"
REV="$2"

# if test "$FILENAME" = "" || test "$REV" = ""; then
if test "$FILENAME" = ""; then
	echo "cvsvimdiff <filename> <revision>"
	echo "  will check out a temporary revision of <filename> and do a vimdiff..."
	exit 1
fi

if test "$REV" = ""; then
	REV=`cvs status "$FILENAME" |
			grep 'Working revision:' |
			after "Working revision:" |
			sed 's/^\( \|	\)//g' |
			getnumber`
	echo "Diffing against current revision $REV"
fi

CKOUT=`jgettmp "$FILENAME-ver-$REV"`

# Check out the specific revision requested

cvs update -p -r "$REV" "$FILENAME" > "$CKOUT"

vimdiff "$FILENAME" "$CKOUT"

# jdeltmp "$CKOUT"
