LINENUM=10000

cat "$@" |

sed 's/^[ ]*[[:digit:]][[:digit:]]*\( \|\)/./' | ## Add .s to lines with line numbers

while read LINE
do
	echo "$LINENUM $LINE"
	LINENUM=`expr "$LINENUM" + 20`
done |

sed 's/^[ ]*[[:digit:]][[:digit:]]* \($\|[^.]\)/\1/' | ## Drop lines with line number but no .
sed 's/^\([ ]*[[:digit:]][[:digit:]]* \)\./\1/' | ## Drop .s from lines with .s
# sed 's/^\([ ]*[[:digit:]][[:digit:]]*\) $/\1/' |
cat
