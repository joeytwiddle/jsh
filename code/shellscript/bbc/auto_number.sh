if [ "$1" = -numall ]
then shift ; NUMBER_ALL=true
fi

LINENUM=10000

cat "$@" |

if [ "$NUMBER_ALL" ]
then
	# sed 's+.*+. \0+' ## Add .s to all lines
	sed 's/^\([ ]*[[:digit:]][[:digit:]]*\( \|\)\|^\)/./' ## Add .s to all lines, stripping line # from those which have it
else sed 's/^[ ]*[[:digit:]][[:digit:]]*\( \|\)/./' ## Add .s to lines with line numbers (and drop line number)
fi |

while read LINE
do
	echo "$LINENUM $LINE"
	LINENUM=`expr "$LINENUM" + 20`
done |

sed 's/^[ ]*[[:digit:]][[:digit:]]* \($\|[^.]\)/\1/' | ## Drop lines with line number but no .
sed 's/^\([ ]*[[:digit:]][[:digit:]]* \)\./\1/' | ## Drop .s from lines with .s
# sed 's/^\([ ]*[[:digit:]][[:digit:]]*\) $/\1/' |
cat
