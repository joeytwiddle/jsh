# unj encodeslashn "$@"

EXPAND_WORDS=
if test "$1" = "-words"
then shift; EXPAND_WORDS=basic
elif test "$1" = "-xwords"
then shift; EXPAND_WORDS=super
fi

NL="
"

unj encodeslashn "$@" |

if test "$EXPAND_WORDS" = basic
then tr ' ' '\n'
elif test "$EXPAND_WORDS" = super
# then sed "s+\( \|	\|\\\\n\)+\\$NL\1\\$NL+g" | tr -s '\n' ## TODO: make this regex a 1+ to match n whitespaces ## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
then sed "s+\( *\|	*\|\\\\n\)+\\$NL\1\\$NL+g" | tr -s '\n' ## TODO: make this regex a 1+ to match n whitespaces ## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
# then sed "s+\( \|	\|\\\\n\|[a-zA-Z]*\)+\\$NL\1\\$NL+g" | tr -s '\n' ## TODO: make this regex a 1+ to match n whitespaces ## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
# then sed "s+\([a-zA-Z]*\|[^a-zA-Z 	]*\|[ 	]*\)+\\$NL\1\\$NL+g" | tr -s '\n' ## TODO: make this regex a 1+ to match n whitespaces ## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
# then sed "s+\(.\)+\\$NL\1\\$NL+g" | tr -s '\n' ## TODO: make this regex a 1+ to match n whitespaces ## NOTE: we will interpret some 'n's wrong, namely this one: "...\\n..."
else cat
fi

## Doesn't work:
## Actually maybe it does, but the sed decoder doesn't.
# sed 's+\\+\\\\+;s+$+\\n+' | tr -d '\n'
