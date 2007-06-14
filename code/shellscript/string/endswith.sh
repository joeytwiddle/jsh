# jsh-ext-depends-ignore: strings
# RESULT=`echo "$1" | grep "$2$"`
# test ! "$RESULT" = ""

if [ "$*" = "" ]
then
	echo "endswith <string> <searchstring> [ ... ]"
	echo "  Returns true if <strings> ends with the characters in <searchstring>."
	echo "  Multiple searchstrings may be offered, any one can return true (0)."
	exit 1
fi

STR="$1"
# [ "$2" = "" ] && exit 0
shift
for SEARCHSTR
do
	[ "$SEARCHSTR" = "" ] && exit 0
	[ ! "${STR%$SEARCHSTR}" = "$STR" ] && exit 0
done
exit 1

## Old method (actually matched regexps instead of strings):
# ## Now accepts multiple options for the end string
# STRING="$1"
# shift
# for PAT
# do
	# if echo "$STRING" | grep "$PAT\$" > /dev/null
	# then exit 0
	# fi
# done
# exit 2
