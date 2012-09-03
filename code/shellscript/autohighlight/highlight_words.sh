#!/bin/bash

## BUG: $COLBOLD has no affect in eterm, so all colors appear dark, but it
## actually has lots of colors we could use!

## With /bin/sh we sometimes get:
##   sed: -e expression #1, char 27: unknown option to `s'

# This rather depends on the context: size and structure of the document.
# A large number of colors filling a small document can be very distracting.
if [ -z "$MAX_WORDS_TO_COLOR" ]
then
	MAX_WORDS_TO_COLOR=7
	# MAX_WORDS_TO_COLOR=14
	# MAX_WORDS_TO_COLOR=99
fi

## Do we want to highlight the most common/abundant words,
TAIL=tail
## or the least popular, more rare words?
if [ "$1" = -rare ]
then TAIL=head ; shift
fi
## This might produce one colour for 16 unique words, if it was not for
## EXCLUDE_SINGLES below, which keeps only words with 2 or more occurrences.

TMPFILE="/tmp/jsh.highlight_words.$$"
cat "$@" > "$TMPFILE"
# cat "$@" | tee "$TMPFILE"   ## Show to user wile he's waiting

# WORD_SPLITTING_CHARS=" "
# WORD_SPLITTING_CHARS="- 	_.,:;=|_/"
WORD_SPLITTING_CHARS=" 	,:;=|/" ## Not so much
# WORD_SPLITTING_CHARS="^[:alpha:][:digit:]"

# EXCLUDE_SINGLES=cat
EXCLUDE_SINGLES="grep -v ^1:"

WORDS=`
# striptermchars |
cat "$TMPFILE" |
striptermchars |
# sed 's+ +\n+g' |
# sed 's+[ =]+\n+g' |
sed "s+[$WORD_SPLITTING_CHARS]+\n+g" |
tr '/$,()' '\n\n\n\n\n' |
grep -v "^ *$" |
countduplicates |
sort -n -k 1 |
$EXCLUDE_SINGLES |
unj $TAIL -n $MAX_WORDS_TO_COLOR |
# pipeboth |
# tee /tmp/hwdata1.$USER |
sort -n -r -k 1 |
dropcols 1 # |
`

# grep -o "\<[[:print:]][[:print:]]*\>"
# extractregex "\<[A-Za-z0-9_+-\.][A-Za-z0-9_+-\.]*\>"

COLHEAD=`printf "\033\[00;"`
# COLNORM=`printf "\033\[00;34m"`
# COLNORM=`curseblue`
COLNORM=`cursenorm`
COLBOLD=`cursebold`

[ "$DEBUG" ] && echo -n "`cursegreen`""WORDS=[ `curseblue`" >&2

SEDEXPR=`
echo "$WORDS" |
toregexp |
PADDING=0 numbereachline |
# pipeboth |
# tee /tmp/hwdata2.$USER |
# sed 's+^00*\(.\)+\1+' |
# sed 's+^00++' |
# sed 's+^0*\([^0]\)+\1+' |
while read NUM WORDREGEXP
do
	# [ "$NUM" -lt 1 ] && NUM=6
	# [ "$NUM" = 7 ] && NUM=1
	# xterm: 6 produces white/grey, 7 loops back to red
	CURSECOL="$((30+((NUM+1)%7)))"
	COL="$COLHEAD$CURSECOL""m"
	## This markes the *rarer* ones bolder than the most popular, only enabled for large MAX_WORDS_TO_COLOR.
	# [ "$NUM" -gt 7 ] || [ "$MAX_WORDS_TO_COLOR" -lt 9 ] && COL="$COL$COLBOLD"
	[ "$NUM" -lt 7 ] && COL="$COL$COLBOLD"
	echo -n "s\<$WORDREGEXP\>$COL""\0""$COLNORMg ; "
	[ "$DEBUG" ] && echo -n "$WORDREGEXP($CURSECOL) " >&2
done
`
	# printf "\033[00;31m" # $((30+NUM))
	# COL=\`printf "\033[00;03$NUM""m"\`
	# COL=\`printf "\033[00;03$NUM""m"\`

[ "$DEBUG" ] && echo "`cursegreen`]`cursenorm`" >&2

# jshinfo "WORDS=[" $WORDS "]"
# jshinfo "SEDEXPR=$SEDEXPR"

cat "$TMPFILE" | sed "$SEDEXPR" |
# cat "$TMPFILE" | unj tail -n 20 | sed "$SEDEXPR"

# tee /tmp/xx2 |

## This is a terminal pretty-printer, so make it friendly too:
more ## (Can cause long lines to split early, as if termcodes were counted as columns)
## If you have most, pipe to that and all will be fine.

