## Consider: Renaming it grepfrom
## Hides all lines until first occurrence of grep pattern (regexp) is met.

if [ "$1" = -x ]
then
	shift
	PAT="$1"
	awk ' BEGIN { X=0 } { if ( X ) { print $0'\n' } } /'"$PAT"'/ { X=1 } '
else
	PAT="$1"
	awk ' BEGIN { X=0 } /'"$PAT"'/ { X=1 } { if ( X ) { print $0'\n' } } '
fi

# OUT="&1" ## Ha! It was saving a file with that name!
# if [ "$1" = -x ]
# then OUT="/dev/null"; shift
# fi
# 
# PAT="$1"
# 
# ## Drop each line until it matches
# while read LINE
# do printf "%s\n" "$LINE" | grep "$PAT" > $OUT && break
# done
# 
# ## Just let the rest of the stream through
# cat
