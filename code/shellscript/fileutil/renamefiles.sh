#!/bin/bash
# jsh-depends: jshwarn
# jsh-depends-ignore: exists
# jsh-ext-depends: sed find tty
# jsh-ext-depends-ignore: file batch rename strings

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "renamefiles [-r] <search_glob> <replace_regex> [<files/dirs>..] [ |sh ]"
	echo
	echo "<command>... | renamefiles <search_glob> <replace_regex> [ |sh ]"
	echo
	echo "  shows you how to rename a batch of files matching the provided glob"
	echo '  (e.g. "*.txt"), using the replacement (which may use \\1,\\2,...).'
	echo
	echo "  To actually perform the renaming, just add |sh to the end of the command."
	echo
	# echo "  In the first instance, the files are those in the current directory,"
	echo "  In the first instance, the file-nodes are found in the current directory,"
	echo "  In the second instance, the list of files is received on standard-in."
	echo
	echo "  The option -r acts recursively, but do check that your search/replace acts on"
	echo "  the filename and not the path."
	echo
	# echo "  NOTE: <search> is a sed regexp, but you must not use \\(...\\) -> \\n args."
	# echo "  TODO: Why not?  It seems to work fine for me!  Ah only method 1 supports it."
	# echo "  NOTE: <search> is a sed regexp, so you can use the \\(...\\) -> \\n feature." ## Using method1 anyway
	echo "  Note: Since renamefiles uses sed, you can use regexp's"' \\(...\\) -> \\n feature.' ## Using method1 anyway
	echo "        But ? and * are interpreted as globs not regexps, and . is a literal."
	echo
	# echo "  grep and sed are used for the selection of files and their renaming,"
	# # echo "  but pre-processing auto-changes . to \. and * to (.*) and ? to . ."
	# echo "  but you should actually specify a glob for <search> and a regexp for <replace>."
	# echo
	echo "  To override aborting when the destination file exists,"
	echo "    export RF_OVERWRITE=anything."
	echo
	echo "Examples:"
	echo
	echo "  To rename file.1 and file.2 to file.01 and file.02"
	echo
	echo "    renamefiles '.\(?\)$' '.0\\\\1'"
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

SEARCH_GLOB="$1"
REPLACE="$2"
shift ; shift

BE_CAREFUL="-i"
[ "$RF_OVERWRITE" ] && BE_CAREFUL="-f"

## Convert SEARCH_GLOB from glob into regexp:
# jshinfo "New stylee: any occurrences of * in the search are auto-converted to \(..*\) , making it easier for you, turning your glob into a regexp"
# jshinfo "Because yes idd \? is also turned into \(.\), and . into \. :)"
SEARCH_REGEXP=`echo -n "$SEARCH_GLOB" | sed 's+\.+\\\\.+g ; s+\\?+\\\\(.\\\\)+g ; s+\*+\\\\(.*\\\\)+g'`
# jshinfo "SEARCH_REGEXP=$SEARCH_REGEXP"

if ! tty >/dev/null
then cat
else find "$@" $MAXDEPTH | sed 's+^\./++'
fi |
grep -e "$SEARCH_REGEXP" |

## Method 1:
while read FILENAME
do
	RENAMEDFILE=`echo "$FILENAME" | sed "s$SEARCH_REGEXP$REPLACE"`
	if [ -e "$RENAMEDFILE" ] && [ ! "$RF_OVERWRITE" ]
	then jshwarn "Skipping \"$FILENAME\", target file already exists: \"$RENAMEDFILE\""
	else echo "mv $BE_CAREFUL \"$FILENAME\" \"$RENAMEDFILE\""
	fi
done

## These two methods do not allow user to use the \(...\) -> \n feature of regexp:
## ( But, they are one-liners, whereas method 1 is a while loop. ;)

## Method 2:
# sed "s+\(.*\)\($SEARCH_REGEXP\)\(.*\)+mv \"\1\2\3\" \"\1$REPLACE\3\"+"

## Method 3:
#sed "s+\(.*\)$SEARCH_REGEXP\(.*\)+mv \"\0\" \"\1$REPLACE\2\"+"

echo
echo "# Press <Up>|sh<Enter> to actually run these commands in a shell."
