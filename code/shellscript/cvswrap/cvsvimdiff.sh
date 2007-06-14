# this-script-does-not-depend-on-jsh: cvsdiff edit filename vimdiff check
# jsh-depends: cvscommit getnumber after editandwait jgettmp jfcsh jdiff jwhich
# Lets you do a diff against a file in CVS with
# vimdiff instead of diff.

FILENAME="$1"
REV="$2"
REV2="$3"

# if test "$FILENAME" = "" || test "$REV" = ""; then
if [ "$FILENAME" = "" ] || [ "$FILENAME" = --help ]
then
	echo
	echo "cvsvimdiff <filename> [ <revision#> [ <another_revision#> ] ]"
	echo
	echo "  will check out a temporary revision(s) of <filename> and do a vimdiff..."
	echo "  no <revision#> means compare against the most recent repository version."
	echo "  You may optionally set \$DIFFCOM to use a different diff program."
	echo
	echo "cvsvimdiff -all"
	echo
	echo "  Will vimdiff all uncommitted files, and commit those you confirm with :w ."
	echo "  (Hence \$DIFFCOM must not bg itself.)"
	echo
	echo "  See also: cvscommit -diff"
	echo
	echo "  Example: env DIFFCOM=jdiff cvsvimdiff ./src/file.c"
	echo
	exit 1
fi

## I think this should be moved to cvscommit -vimdiff or somesuch
## "vim" should be removed from script names, since they are not really vim-specific
if [ "$FILENAME" = "-all" ]
then
	cvscommit -vimdiff
	exit
fi

# WHICHREV="Working"
WHICHREV="Repository"
if [ "$REV" = "" ]
then
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
verbosely cvs -q update -p -r "$REV" "$FILENAME" > "$CKOUT" || exit

if [ ! "$REV2" = "" ]
then
	CKOUT2=`jgettmp "$FILENAME-ver-$REV2"`
	# Check out the other revision requested
	verbosely cvs -q update -p -r "$REV2" "$FILENAME" > "$CKOUT2" || exit
	# Adjust vars so that vimdiff runs on the two checked out files.
	FILENAME="$CKOUT"
	CKOUT="$CKOUT2"
fi

if [ "$DIFFCOM" = "" ]
then
	DIFFCOM="vimdiff"
	# DIFFCOM="vimdiff -c"
	# DIFFCOMARG=":syn off
# :set wrap"
	if [ "`jwhich $DIFFCOM`" = "" ]
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
