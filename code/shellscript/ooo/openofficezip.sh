#!/bin/sh
DIR="$1"
FILE=`echo "$1" | sed 's/.unzipped//'`
while test -f "$FILE"; do
	FILE=`echo "$FILE" | sed 's+\(.*\)\.\(.*\)+\1.new.\2+'`
done
FILE=`absolutepath "$FILE"`

cd "$DIR"
for X in *.xml; do
	cat "$X" | tr -d "\n\t" > tmp.xml
	mv tmp.xml "$X"
done

zip -r "$FILE" *
