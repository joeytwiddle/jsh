#!/bin/sh
## For all files under working directory, compares to same file in path provided.
## If files match, displays command to remove it.

echo "# Dangers:"
echo "# Are you sure the files you are comparing aren't symlinks to themselves?!"
echo "# It could be a parent directory causing the problem of course."
echo "# We could check this if we trust realpath to untangle the links."
echo "# To execute once satisfied use | sh , not \`...\`"
# echo "# (or use -doit, which I implemented after neglecting to read this message!)"
echo "# (or even better, use -doit, to avoid problems with strange filenames)"
echo "# DO NOT run \"removeduplicatefiles .\" !!!"
echo "#"

OTHERDIR="$1"
if [ ! "$OTHERDIR" ]
then
	echo "# Syntax: removeduplicatefiles [-doit] <other-dir>"
	echo "  You don't want to run \"removeduplicatefiles .\"!  Instead try \"findduplicatefiles .\"."
	exit 1
fi
DOIT=false
if test "$OTHERDIR" = "-doit"; then
	DOIT=true
	OTHERDIR="$2"
fi
# WHAT="$2"
# if test "x$WHAT" = "x"; then
#   WHAT="*";
# fi

find . -type f |
while read X
do
	CMPRES=`cmp "$X" "$OTHERDIR/$X" 2>&1`
	CMPERR="$?"
	if [ ! "$CMPRES" ]
	then
		if [ "$CMPERR" = "0" ]
		then
			# For the chop!
			# if cmp "$X" "$OTHERDIR/$X" 2>&1
			# then
				if [ "$DOIT" = "false" ]
				then echo "rm \"$X\"" # "    # err=$CMPERR output=$CMPRES"
				else rm "$X"
				fi
			# else echo "# `cursered;cursebold`*** ERROR:  $X : failed on if cmp`cursenorm`" >&2
			# fi
		else echo "# `cursered;cursebold`*** ERROR: $X : err > 0 but output: $CMPRES`cursenorm`" >&2
		fi
	else
		if [ "$CMPERR" = "0" ]
		then
			echo "# `cursered;cursebold`*** ERROR: $X : err=0 but got output: $CMPRES`cursenorm`" >&2
		else
			NICECMPRES=`echo "$CMPRES" | tr "\n" "\\n" | after "$X"`
			echo "# `cursemagenta`$X is unique ($NICECMPRES)`cursenorm`"
		fi
	fi
done

echo "#"
echo "# Dangers:"
echo "# Are you sure the files you are comparing aren't symlinks to themselves?!"
echo "# It could be a parent directory causing the problem of course."
echo "# We could check this if we trust realpath to untangle the links."
echo "# To execute once satisfied use | sh , not \`...\`"
echo "# (or use -doit, which I implemented after neglecting to read this message!)"

