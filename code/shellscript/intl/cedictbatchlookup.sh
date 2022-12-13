#!/bin/sh
# TODO
# At the moment, we make a sed rule for every dict lookup of the character.
# This results in only the first being displayed (or worse, mega-embedding!).
# Ideally, the various lookups for a char should be collated together.

ALLCHARS="$1"

if test ! -f "$ALLCHARS"; then
	echo "cedictbatchlookup <char_list_file>"
	echo "  will return lookups for all the Chinese chars."
	echo "  <file> must contain a list of '\n' delimeted Chinese chars."
	exit 0
fi

ALLCHARS2=`jgettmp allchars2`

for DICT in g b; do
	# Need to pass big5/gb to cedictlookup:
	echo "$DICT" > "$ALLCHARS2"
	cat "$ALLCHARS" |
		# This sed is a workaround perl "..@.." problem.
		sed "s/@/\\\\@/g" |
		# Oh dear we still have final sed problems
		# This avoids but loses valid characters!
		# sed "s/[ -~]//g" |
		tr -d "¬°" |
		# tr -d "¬°¤¤§'¨" |
		cat >> "$ALLCHARS2"
	cedictlookup < "$ALLCHARS2"
done | tee "lookup" |
	grep "] /" |
	sed "s/Enter word (-h for help): //" |
	# grep -E ".*: .. \[[^]]*\] .*" |
	sed "s+.*: \(..\) \[\([^]]*\)\] \(.*\)+ s|\1|\1 (\2 : \3)| +" |
	sed "s+/+<br>+g"
