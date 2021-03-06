#!/bin/sh
if [ "$1" = "" ]
then
	echo "jtag <file>... <tag>"
	echo "jtag <file>... - <tag>..."
	echo "  will add <tag>(s) to all .<file>.jtag"
	echo "jtag <file>"
	echo "jtag - <file>..."
	echo "  wil edit tags for <file>(s)"
	exit 1
fi

tagfilefor() {
	DIR=`dirname "$1"`
	FILE=`filename "$1"`
	echo "$DIR/.$FILE.jtag"
}

FILES=""

while [ ! "$2" = "" ] && [ ! "$1" == "-" ]
do
	FILES="$FILES$1
"
	shift
done

if [ "$1" = "-" ]
then shift
fi

if [ "$FILES" = "" ]
then
	## TODO: Construct an edit ... line to open all in one editor
	for FILE
	do
		# FILE="$1"
		TAGFILE=`tagfilefor "$FILE"`
		edit "$TAGFILE"
	done
fi

TAGS=""

while [ ! "$1" = "" ]
do
	TAGS="$TAGS$1
"
	shift
done

FILE="$1"

printf "$FILES" |
while read FILE
do
	if [ ! -e "$FILE" ]
	then
		echo "jtag: aborting since file does not exist: $FILE"
		exit 2
	fi
	TAGFILE=`tagfilefor "$FILE"`
	echo "Adding "`printf "$TAGS" | tr "\n" ","`" to $TAGFILE"
	printf "$TAGS" >> "$TAGFILE"
done
