#!/bin/sh
## e.g.: nodecount ./* | sort -n -k 2 | columnise

for DIR
do
	COUNT=`find "$DIR" | wc -l`
	printf "%s\t%s\n" "$COUNT" "$DIR"
done
