# unj escapenewlines "$@"

# echo "  '\\'s and '\\n's are slash-escaped."
# echo "  If -x is specified, then after escaping words and some special characters are"
# echo "  expanded onto separate lines."
# echo "  One example use of this is to perform diffing by words rather than by lines."

EXPAND_WORDS=
if test "$1" = -x
then shift; EXPAND_WORDS=true
fi

NL="
"

# unj escapenewlines "$@" |   ## C version
sed 's+\\+\\\\+g;s+$+\\n+' "$@" | tr -d '\n' |

if test "$EXPAND_WORDS"
then
	## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
	#   whole-word whitespace+special-chars escaped-newline  ## Sufficient for my HTML purposes
	sed "s=\([a-zA-Z]+\|\[0-9\.]+\|[ \=\./;\"'<>]\|\\\\n\)=\\$NL\1\\$NL=g" |
	tr -s '\n'
	# sed "s=\([a-zA-Z]+\|\[0-9\.]+\|[ 	]+\|[\=\./;\"'<>]\|\\\\n\)=\\$NL\1\\$NL=g" |
	## Others (testing):
	# sed "s=\([a-zA-Z]+\|[ 	]+\|[;\"'<>]\|\\\\n\)=\\$NL\1\\$NL=g" |
	# sed "s=\([a-zA-Z]+\|[ 	]+\|[;\"'<>]\|\\\\n\|[^a-zA-Z 	;\"'<>\\]*\)=\\$NL\1\\$NL=g" |
	# sed "s+\( \|	\|\\\\n\|[a-zA-Z]*\)+\\$NL\1\\$NL+g"
	# sed 's+\( \|	\|\\\\n\)+'"\\$NL\1\\$NL+g"
	# sed "s+\( +\|	+\|\\\\n\)+\\$NL\1\\$NL+g"
	# sed "s+\([a-zA-Z]+\|[^a-zA-Z 	]+\|[ 	]+\)+\\$NL\1\\$NL+g"
	# sed "s+\(.\)+\\$NL\1\\$NL+g"
else cat
fi
