#!/bin/sh

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "gitvimdiff <filename>"
	echo
	echo "gitvimdiff <commit> <filename>"
	echo
	echo "gitvimdiff -n <num> <filename>"
	echo
	echo "  will check out a temporary version of <filename> and do a vimdiff against"
	echo "  the working file."
	echo
	echo "  The first form diffs against the most recent commit."
	echo
	echo "  The -n form goes <num> revisions back in the revision history of that file,"
	echo "  to save you from having to look up the commit id."
	echo
	echo "  You may set \$DIFFCOM to use a different program to compare the two files."
	echo
	exit 1
fi

if [ -n "$1" ] && [ "$2" = "" ]
then
	revisionIndex=1
	filename="$1"
	shift
elif [ "$1" = '-n' ]
then
	shift
	revisionIndex="$1"
	shift
	filename="$1"
	shift
else
	commitID="$1"
	shift
	filename="$1"
	shift
fi

if [ -n "$1" ]
then echo 'Too many arguments given!' ; exit 1
fi

if [ -n "$revisionIndex" ]
then
	if [ "$revisionIndex" -lt 1 ]
	then echo 'revisionIndex should be >= 1!' ; exit 1
	fi
	commitID=`git log "$filename" | grep --line-buffered "^commit " | head -n "$revisionIndex" | tail -n 1 | cut -d ' ' -f 2`
	# CONSIDER: Perhaps we could just use HEAD^$revisionIndex or HEAD~~$revisionIndex ?
fi

olderFile="$filename"."$commitID"

verbosely git diff "$commitID" "$filename" |
# cat | diffhighlight
patch -R -o "$olderFile" "$filename"
# CONSIDER: Instead of patching, perhaps we could use `git cat-file`.

[ "$DIFFCOM" ] || DIFFCOM="vimdiff"

"$DIFFCOM" "$olderFile" "$filename"

