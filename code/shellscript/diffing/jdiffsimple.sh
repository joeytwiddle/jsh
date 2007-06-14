## A nice simple visual diff for the console.  See also: jdiff
## It prints the file, with common lines in white, removed lines red, and added lines green.
## So to "see" the original file, simply ignore all the green lines, or to "see" the new file, ignore only red lines.

if [ "$1" = -fine ]
then

	## TODO: Should really implement "$FILEA".xescaped etc. as tmpfiles

	shift
	FILEA="$1"
	FILEB="$2"
	shift; shift
	cat "$FILEA" | escapenewlines -x > "$FILEA".xescaped
	cat "$FILEB" | escapenewlines -x > "$FILEB".xescaped
	jdiffsimple "$FILEA".xescaped "$FILEB".xescaped "$@" |
	unescapenewlines -x

	del "$FILEA".xescaped "$FILEB".xescaped

else

	## BUG: sometimes common lines get printed in red, white and green!!
	##      but then vimdiff can't group them right either, so we can't really complain.
	# diff --changed-group-format="`cursered`%<`cursegreen`%>`cursenorm`%=" "$@"

	## OK well the previous did sometimes manage to print old lines in both red and white, which wasn't good.
	## This approach seems to work better:
	diff --old-line-format="`cursered`%L`cursenorm`" --new-line-format="`cursegreen`%L`cursenorm`" "$@"

	cursenorm # polite innit

fi
