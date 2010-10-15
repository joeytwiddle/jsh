TAIL=tail
if [ "$1" = -rare ]
then TAIL=head ; shift ## Often (but not always) one colour for 16 unique words.
fi

TMPFILE="/tmp/jsh.highlight_words.$$"
cat "$@" > "$TMPFILE"

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
numbereachline |
# pipeboth |
# sed 's+^00*\(.\)+\1+' |
sed 's+^00++' |
while read NUM WORD
do
	# [ "$NUM" -lt 1 ] && NUM=6
	# [ "$NUM" = 7 ] && NUM=1
	CURSECOL="$((31+((NUM+1)%7)))"
	COL="$COLHEAD$CURSECOL""m"
	[ "$NUM" -lt 8 ] || COL="$COL$COLBOLD"
	echo -n "s+\<$WORD\>+$COL""\0""$COLNORM+g ; "
	[ "$DEBUG" ] && echo -n "$WORD($CURSECOL) " >&2
done
`
	# printf "\033[00;31m" # $((30+NUM))
	# COL=\`printf "\033[00;03$NUM""m"\`
	# COL=\`printf "\033[00;03$NUM""m"\`

[ "$DEBUG" ] && echo "`cursegreen`]`cursenorm`" >&2

# echo "WORDS=[" $WORDS "]"
# echo "SEDEXPR=$SEDEXPR"

cat "$TMPFILE" | sed "$SEDEXPR"
# cat "$TMPFILE" | unj tail -n 20 | sed "$SEDEXPR"

