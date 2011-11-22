#!/bin/bash

## With /bin/sh we sometimes get:
##   sed: -e expression #1, char 27: unknown option to `s'


TAIL=tail
if [ "$1" = -rare ]
then TAIL=head ; shift ## Often (but not always) one colour for 16 unique words.
fi

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
unj $TAIL -n 16 |
# pipeboth |
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
COLGREEN=`cursegreen`
COLCYAN=`cursecyan`

[ "$DEBUG" ] && echo -n "`cursegreen`""WORDS=[ `curseblue`" >&2

SEDEXPR=`
echo "$WORDS" |
toregexp |
numbereachline |
# pipeboth |
# sed 's+^00*\(.\)+\1+' |
sed 's+^00++' |
while read NUM WORDREGEXP
do
	# [ "$NUM" -lt 1 ] && NUM=6
	# [ "$NUM" = 7 ] && NUM=1
	CURSECOL="$((31+((NUM+1)%7)))"
	COL="$COLHEAD$CURSECOL""m"
	[ "$NUM" -lt 8 ] || COL="$COL$COLBOLD"
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

