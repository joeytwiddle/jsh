# unj escapenewlines "$@"

EXPAND_WORDS=
if test "$1" = -x
then shift; EXPAND_WORDS=true
fi

NL="
"

# unj escapenewlines "$@" |   ## C version
sed 's+\\+\\\\+;s+$+\\n+' "$@" | tr -d '\n' |

if test "$EXPAND_WORDS"
then
	## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
	#   whole-word whitespace special-chars escaped-newline  ## Sufficient for my HTML purposes
	sed "s=\([a-zA-Z]+\|[ 	]+\|[;\"'<>]\|\\\\n\)=\\$NL\1\\$NL=g" |
	tr -s '\n'
	## Others (testing):
	# sed "s=\([a-zA-Z]+\|[ 	]+\|[;\"'<>]\|\\\\n\|[^a-zA-Z 	;\"'<>\\]*\)=\\$NL\1\\$NL=g" |
	# sed "s+\( \|	\|\\\\n\|[a-zA-Z]*\)+\\$NL\1\\$NL+g"
	# sed 's+\( \|	\|\\\\n\)+'"\\$NL\1\\$NL+g"
	# sed "s+\( +\|	+\|\\\\n\)+\\$NL\1\\$NL+g"
	# sed "s+\([a-zA-Z]+\|[^a-zA-Z 	]+\|[ 	]+\)+\\$NL\1\\$NL+g"
	# sed "s+\(.\)+\\$NL\1\\$NL+g"
else cat
fi
