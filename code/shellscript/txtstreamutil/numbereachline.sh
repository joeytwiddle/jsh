#!/bin/sh

# e.g. PADCHAR=0
[ -z "$PADDING" ] && PADDING=3
# e.g. PADCHAR=" "
[ -z "$PADCHAR" ] && PADCHAR='0'

[ -z "$DELIM" ] && DELIM="\t"

# e.g. PADSTR="%03i"
PADSTR="%0${PADDING}i"

N=0
escapeslash | ## since echo "$LINE" will lose \s if not doubled.  BUG: what else might echo "$LINE" lose?
while read LINE
do
	# printf "%s\n" "$N	$LINE"
	printf "${PADSTR}${DELIM}%s\n" "$N" "$LINE"
	N=$(($N+1))
done
