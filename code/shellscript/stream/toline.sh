## Consider: Renaming it grepto, or maybe awkto now!
## TODO: awk doesn't handle /s well, need to \/ escape them
## Hides all lines after first occurrence of grep pattern (regexp) is met.

## Might be useful to escape '/'s, '&'s, and '?'s:
# sed 's+\(/\|\&\|\?\)+\\\\\1+g'

AWKOPTS=""
## Interactive mode is line-buffered, which can be nice if you want to watch output until line is reached, but only available with mawk.
if realpath `which awk` | grep /mawk > /dev/null
then AWKOPTS="-W interactive"
fi

if [ "$1" = -x ]
then
	shift
	PAT="$1"
	awk $AWKOPTS ' /'"$PAT"'/ { exit } { print $0'\n' } '
else
	PAT="$1"
	awk $AWKOPTS ' { print $0'\n' } /'"$PAT"'/ { exit } '
fi

# echo "AWK OVER" >&2

## Drop the rest of the stream
## By backgrounding this I hope to avoid "broken stream/pipe" errors,
## but still achieve that alternate functionality, which is,
## rather than to chop a stream at a certain point,
## to wait until a certain point in a stream is reached
## (eg. watching for particular even in a logfile).
## TODO: Note I also had to make awk interactive to achieve this, which is actually a mawk option that might cause problems on Solaris, etc.

## Didn't work on orion: cat > /dev/null &
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
