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

## Now accepts multiple options for the end string
STRING="$1"
shift
for PAT
do
	if echo "$STRING" | grep "$PAT\$" > /dev/null
	then exit 0
	fi
done
exit 2
