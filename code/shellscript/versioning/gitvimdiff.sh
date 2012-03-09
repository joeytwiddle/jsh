if [ "$1" = "" ] || [ "$2" = "" ] || [ "$1" = --help ]
then
	echo
	echo "gitvimdiff <commit> <filename>"
	echo
	echo "gitvimdiff -n <num> <filename>"
	echo
	echo "  will check out a temporary version of <filename> and do a vimdiff..."
	echo
	echo "  You may set \$DIFFCOM to use a different program to compare the files."
	echo
	echo "  The -n form goes <num> revisions back, so you don't have to lookup the commit ids."
	echo
	exit 1
fi

if [ "$1" = -n ]
then
	shift
	revisionIndex="$1"
	shift
	filename="$1"
	commitID=`git log "$filename" | grep "^commit " | head -n "$revisionIndex" | tail -n 1 | cut -d ' ' -f 2`
else
	commitID="$1"
	shift
fi

filename="$1"

olderFile="$filename"."$commitID"

verbosely git diff "$commitID" "$filename" |
# cat | diffhighlight
patch -R -o "$olderFile" "$filename"

[ "$DIFFCOM" ] || DIFFCOM="vimdiff"

"$DIFFCOM" "$olderFile" "$filename"

