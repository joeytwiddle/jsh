# jsh-ext-depends-ignore: file batch rename strings
# jsh-ext-depends: sed find tty
# jsh-depends: jshwarn
# this-script-does-not-depend-on-jsh: exists
if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "renamefiles [-r] <search> <replace> [ |sh ]"
	echo
	echo "<command>... | renamefiles <search_glob> <replace_regexp> [ |sh ]"
	echo
	echo "  allows you to easily rename a batch of files by simply providing"
	echo "  a glob to match, and a regexp-style (\1,\2,...) replacement string."
	echo
	# echo "  In the first instance, the files are those in the current directory,"
	echo "  In the first instance, the file-nodes are found in the current directory,"
	echo "  In the second instance, the list of files is fed in."
	echo
	echo "  grep and sed are used for the selection of files and their renaming,"
	# echo "  but pre-processing auto-changes . to \. and * to (.*) and ? to . ."
	echo "  but you should actually specify a glob for <search> and a regexp for <replace>."
	echo
	echo "  The option -r acts recursively, but do check that your search/replace acts on the filename and not the path."
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

if [ "$1" = -r ]
then MAXDEPTH="" ; shift
else MAXDEPTH="-maxdepth 1"
fi

SEARCH="$1"
REPLACE="$2"

## Convert SEARCH from glob into regexp:
# jshinfo "New stylee: any occurrences of * in the search are auto-converted to \(..*\) , making it easier for you, turning your glob into a regexp"
# jshinfo "Because yes idd \? is also turned into \(.\), and . into \. :)"
SEARCH=`echo "$SEARCH" | sed 's+\.+\\\\.+g ; s+\\?+\\\\(.\\\\)+g ; s+\*+\\\\(.*\\\\)+g'`
# jshinfo "SEARCH=$SEARCH"

if ! tty >/dev/null
then cat
# else find . -type f -maxdepth 1
else find . $MAXDEPTH
fi |
grep "$SEARCH" |

## Method 1:
while read FILENAME
do
	RENAMEDFILE=`echo "$FILENAME" | sed "s$SEARCH$REPLACE"`
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

