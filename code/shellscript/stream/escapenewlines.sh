#!/bin/sh
# jsh-ext-depends-ignore: file
# jsh-ext-depends: sed
# this-script-does-not-depend-on-jsh: after
# unj escapenewlines "$@"

## This tty call might slow things down, but it's my first attempt at using tty to check whether
## we are part of a pipe, or called directly from an interactive user shell, and it is useful!
## Oh it is actually undesirable after all!
if [ "$1" = --help ] # || tty > /dev/null
then
	echo
	echo "escapenewlines [ -x ] [ <file> ]*"
	echo
	echo "  '\\'s and '\\n's are '\\'-escaped, so you get a stream with no real newlines."
	echo
	echo "  If -x is specified, then after escaping, words and some special characters are"
	echo "  separated onto individual lines (because real '\\n's no longer mean anything)."
	echo "  One example use of this is to perform diffing by words rather than by lines."
	echo
	echo "  For an example, try: ls / | escapenewlines; echo"
	echo
	exit 1
fi

EXPAND_WORDS=
if [ "$1" = -x ]
then shift; EXPAND_WORDS=true
fi

NL="
"

# unj escapenewlines "$@" |   ## C version
sed 's+\\+\\\\+g;s+$+\\n+' "$@" | tr -d '\n' |

if [ "$EXPAND_WORDS" ]
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
