## Consider: Renaming it grepto, or maybe awkto now!
## TODO: awk doesn't handle /s well, need to \/ escape them
## Hides all lines after first occurrence of grep pattern (regexp) is met.

if [ "$1" = -x ]
then
	shift
	PAT="$1"
	awk ' /'"$PAT"'/ { exit } { print $0'\n' } '
else
	PAT="$1"
	awk ' { print $0'\n' } /'"$PAT"'/ { exit } '
fi

## Drop the rest of the stream
cat > /dev/null

# # OUT="/dev/stdout"
# OUT="&1" ## Ha! It was saving a file with that name!
# if [ "$1" = -x ]
# then OUT="/dev/null"; shift
# fi
# 
# PAT="$1"
# 
# ## Print each line until a match is found
# while read LINE
# do
	# printf "%s\n" "$LINE" | grep "$PAT" > $OUT && break
	# printf "%s\n" "$LINE"
# done
# 
# ## Drop the rest of the stream
# cat > /dev/null
