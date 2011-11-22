#!/bin/sh
## Collects all symlinks in the current directory tree into a single text file, and deletes them.
## They may be restored with expandsymlinks.
## Run this then cvs commit the .symlinks.list file!

find . -type l |
while read X
do
	'ls' -ld "$X"
	# echo "$X" >&2
	# rm "$X"
	# rmlink "$X"
done |
sed 's| -> |	->	|' |
sed 's|.* \([^ 	]*	->	.*\)|\1|' |
sort | ## Sorting is relevant if this file is to be diffed!
cat > .symlinks.list
