#!/bin/sh
## Intention: Given an artist and track name, find the lyrics
##   for the song by searching Google, and trying to find concensus
##   on the lyrics from a number of pages.
## Current status: trying to extract the relevant links from
##   the Google search.
## TODO: Cannot take every 3rd link because there is
##   occasionally extra links like "More results from X"

## I think this has now been superceded by seeklyrics

if test "$*" = ""; then
	echo "findlyrics <artist> <song_name>"
	echo "  see seeklyrics - probably better"
	exit 1
fi

GOOGLESEARCH=`jgettmp googlesearchresults`

QUERYSTR=`
	echo "lyrics \"$1\" \"$2\"" |
	tr " " "+" |
	sed 's+"+%22+g'
`

lynx -dump "http://www.google.com/search?q=$QUERYSTR&num=20" > "$GOOGLESEARCH"

LAST=`expr 12 + 3 '*' '(' 20 - 1 ')'`

for X in `seq 12 3 $LAST`; do
	URL=`
	cat "$GOOGLESEARCH" |
	fromstring "References" |
	grep "^[ ]*$X\. http://" |
	sed "s/^[ ]*$X\. //"
	`
	echo "$URL"
done
