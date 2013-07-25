#!/bin/sh
## TODO: jdiffsimple -fine sometimes seems to \r the last line (or few lines).  It also randomly prints 14+4 at the top!
## TODO: Also -fine prints 4 removed spaces as "- - - - "!
## `jdiffsimple -fine` achieves something similar to http://homepages.inf.ed.ac.uk/imurray2/compnotes/cwdiff

if [ ! "$*" ] || [ "$1" = --help ]
then
	echo "jdiffsimple [-fine] <files>"
	echo "  A nice simple visual diff for the console.  See also: jdiff"
	echo "  It prints the file, with common lines in white, removed lines red, and added lines green."
	echo "  So to \"see\" the original file, simply ignore all the green lines, or to \"see\" the new file, ignore only red lines."
	echo "  -fine will search for changes around words instead of at line breaks."
	exit 0
fi

if [ "$1" = -fine ]
then

	shift
	FILEA="$1"
	FILEB="$2"
	shift; shift
	cat "$FILEA" | escapenewlines -x > "$FILEA".xescaped
	cat "$FILEB" | escapenewlines -x > "$FILEB".xescaped
	[ "$JDSCONTEXT" ] || JDSCONTEXT="-C20"
	JDSCONTEXT="$JDSCONTEXT" jdiffsimple "$FILEA".xescaped "$FILEB".xescaped "$@" |
	unescapenewlines -x

	rm -f "$FILEA".xescaped "$FILEB".xescaped

else

	## BUG: sometimes common lines get printed in red, white and green!!
	##      but then vimdiff can't group them right either, so we can't really complain.
	# diff --changed-group-format="`cursered`%<`cursegreen`%>`cursenorm`%=" "$@"

	## OK well the previous did sometimes manage to print old lines in both red and white, which wasn't good.
	## This approach seems to work better:
	# diff --old-line-format="`cursered`%L`cursenorm`" --new-line-format="`cursegreen`%L`cursenorm`" "$@"

	[ "$JDSCONTEXT" ] || JDSCONTEXT="-C3"

	## TODO: Might not work well with -fine
	ADD_COL="`cursegreen`"
	REMOVE_COL="`cursered`"
	# PRE_ADD="`cursemagenta``cursebold`+" ## These are good for a few changes, but can be terrible when doing fine diffing, adding far more '+'s a nd '-'s than needed.
	# PRE_REMOVE="`cursemagenta``cursebold`-"
	RESET_COL="`cursenorm`"
	diff --old-line-format="$PRE_REMOVE$REMOVE_COL%L$RESET_COL" --new-line-format="$PRE_ADD$ADD_COL%L$RESET_COL" "$@" |
	# grep "$JDSCONTEXT" "\(`toregexp "$PRE_REMOVE"`\|`toregexp "$PRE_ADD"`\)" |
	grep "$JDSCONTEXT" "\(`toregexp "$REMOVE_COL"`\|`toregexp "$ADD_COL"`\)" |
	sed "s|^--$|`curseblue` ... `cursenorm`|"

	cursenorm # safe side

fi
