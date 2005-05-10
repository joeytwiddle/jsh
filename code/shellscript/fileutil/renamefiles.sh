# jsh-ext-depends-ignore: file batch rename strings
# jsh-ext-depends: sed find tty
# jsh-depends: jshwarn
# jsh-depends-ignore: exists
if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "renamefiles <search> <replace> [ |sh ]"
	echo
	echo "<command>... | renamefiles <search> <replace> [ |sh ]"
	echo
	echo "  allows you to easily rename a batch of files by simply providing"
	echo "  a regular expression to match, and a replacement."
	echo
	echo "  In the first instance, the files are those in the current directory,"
	echo "  In the second instance, the list of files is fed in."
	echo
	echo "  Pipe the output through |sh if you are happy."
	echo
	# echo "  NOTE: <search> is a sed regexp, but you must not use \\(...\\) -> \\n args."
	# echo "  TODO: Why not?  It seems to work fine for me!  Ah only method 1 supports it."
	# echo "  NOTE: <search> is a sed regexp, so you can use the \\(...\\) -> \\n feature." ## Using method1 anyway
	echo "  NOTE: Since renamefiles uses sed, you can use regexp's \\(...\\) -> \\n feature." ## Using method1 anyway
	echo
	echo "  TODO: May need to implement extra escaping for really nasty chars."
	echo "        Bugreports (example failure strings) are welcome."
	echo
	exit 1
fi

SEARCH="$1"
REPLACE="$2"

if ! tty
then cat
else find . -type f -maxdepth 1
fi |
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

## These two methods do not allow user to use the \(...\) -> \n feature of regexp:
## ( But, they are one-liners, whereas method 1 is a while loop. ;)

## Method 2:
# sed "s+\(.*\)\($SEARCH\)\(.*\)+mv \"\1\2\3\" \"\1$REPLACE\3\"+"

## Method 3:
#sed "s+\(.*\)$SEARCH\(.*\)+mv \"\0\" \"\1$REPLACE\2\"+"

