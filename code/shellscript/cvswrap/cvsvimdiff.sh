# jsh-depends-ignore: cvsdiff edit filename vimdiff
# jsh-depends: cvscommit getnumber after editandwait jgettmp jfcsh jdiff jwhich
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

## I think this should be moved to cvscommit -vimdiff or somesuch
## "vim" should be removed from script names, since they are not really vim-specific
if test "$FILENAME" = "-all"
then
	cvscommit -vimdiff
	exit
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
	echo "Diffing $FILENAME against $WHICHREV revision $REV"
fi

# Check out the specific revision requested
CKOUT=`jgettmp "$FILENAME-ver-$REV"`
cvs -q update -p -r "$REV" "$FILENAME" > "$CKOUT"

if test ! "$REV2" = ""; then
	CKOUT2=`jgettmp "$FILENAME-ver-$REV2"`
	# Check out the other revision requested
	cvs -q update -p -r "$REV2" "$FILENAME" > "$CKOUT2"
	# Adjust vars so that vimdiff runs on the two checked out files.
	FILENAME="$CKOUT"
	CKOUT="$CKOUT2"
fi

if test "$DIFFCOM" = ""; then
	DIFFCOM="vimdiff"
	# DIFFCOM="vimdiff -c"
	# DIFFCOMARG=":syn off
# :set wrap"
	if test "`jwhich $DIFFCOM`" = ""
	then
		export DIFFCOM=simplediff
		simplediff () {
			while true
			do
				jfcsh -bothways "$1" "$2"
				jdiff "$1" "$2"
				echo "Press <Enter> to move on, e<Enter> to edit, or <anything><Enter> to commit."
				read KEY
				if test "$KEY" = e
				then editandwait "$1"; continue
				fi
				if test ! "$KEY" = ""
				then touch "$1"
				fi
				break
			done
		}
	fi
fi

$DIFFCOM "$FILENAME" "$CKOUT"
# $DIFFCOM "$DIFFCOMARG" "$FILENAME" "$CKOUT"
# -c ':syn off<Enter>:set wrap<Enter>'

# jdeltmp "$CKOUT"
# haven't handle'd second case, don't want to delete original file!!
