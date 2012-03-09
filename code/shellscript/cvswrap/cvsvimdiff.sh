#!/bin/sh

# Lets you do a diff against a file in CVS with
# vimdiff instead of diff.

# jsh-depends: cvscommit getnumber after editandwait jgettmp jfcsh jdiff jwhich
# jsh-depends-ignore: cvsdiff edit filename vimdiff check

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
	echo "  (Hence \$DIFFCOM must not background itself!)"
	echo
	echo "  See also: cvscommit -diff"
	echo
	echo "  Different look: env DIFFCOM=jdiff cvsvimdiff ./src/file.c"
	echo
	echo '  Unordered lines: env DIFFCOM="jfcsh -bothways" cvsvimdiff init'
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

# I like to show the repository version on the right-hand side, although this
# is not chronological and is atypical for me, this layout reminds me of the
# thing I will be overwriting/changing, the repository copy on the right!
# If I place the original version on the left, I ignore it and assume
# everything on the right (the commit) is correct.
# If the original is on the right, I think about what the commit will be
# changing, and am more tempted to trim down my commit and give it further
# consideration.
# (Remember kids: Editing commits without testing them is bad!  So perhaps a
# chronological layout would be better, if we decide commits are good from
# having tested them, not from having read them!)

# Don't think this is a problem: haven't handled second case, don't want to delete original file!!
jdeltmp "$CKOUT"
[ "$CKOUT2" ] && jdeltmp "$CKOUT2"
