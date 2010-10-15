#!/bin/sh
FILE="$1"
DIR="$1.unzipped"

mkdir -p "$DIR"
unzip -d "$DIR" "$FILE"

## Note: sed only really desirable if OOffice XML compression is on (default)

cd "$DIR"
for X in *.xml; do
	cat "$X" | sed 's+><+>\
<+g' > tmp.xml
	mv tmp.xml "$X"
done
