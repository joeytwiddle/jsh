if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "renamefiles <search> <replace> | sh"
	echo
	echo "  allows you to easily rename a batch of files in the current directory,"
	echo "  by simply providing a regular expression to match, and a replacement."
	echo
	echo "  NOTE: <search> is a sed regexp, but you must not use \\(...\\) -> \\n args."
	echo
	echo "  TODO: May need to implement extra escaping for really nasty chars."
	echo "        Bugreports welcome."
	echo
	exit 1
fi

SEARCH="$1"
REPLACE="$2"

find . -type f -maxdepth 1 |
grep "$SEARCH" |

## Method 1:
while read FILENAME
do
	RENAMEDFILE=`echo "$FILENAME" | sed "s+$SEARCH+$REPLACE+"`
	if [ -e "$RENAMEDFILE" ]
	then jshwarn "Skipping \"$FILENAME\", target file already exists: \"$RENAMEDFILE\""
	else echo "mv \"$FILENAME\" \"$RENAMEDFILE\""
	fi
done

## Method 2:
# sed "s+\(.*\)\($SEARCH\)\(.*\)+mv \"\1\2\3\" \"\1$REPLACE\3\"+"

## Method 3:
#sed "s+\(.*\)$SEARCH\(.*\)+mv \"\0\" \"\1$REPLACE\2\"+"
