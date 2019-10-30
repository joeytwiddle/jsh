#!/bin/sh
## Streams standard in to standard out, until given awk regexp is reached (exclusive with -x).

## Consider: Renaming it grepto, or maybe awkto now!
## TODO: awk doesn't handle /s well, need to \/ escape them
## Hides all lines after first occurrence of grep pattern (regexp) is met.

## See also: <koala_man> eille-la: sed '/line/q'

## Might be useful to escape '/'s, '&'s, and '?'s:
# sed 's+\(/\|\&\|\?\)+\\\\\1+g'

# jsh-ext-depends-ignore: mawk realpath gawk
# jsh-depends: realpath

AWKOPTS=""
## Interactive mode is line-buffered, which can be nice if you want to watch output until line is reached, but only available with mawk.
if realpath "$(which awk 2>/dev/null)" | grep "/gawk$" > /dev/null
then AWKADD="{ fflush(); }"
elif realpath "$(which awk 2>/dev/null)" | grep "/mawk$" > /dev/null
then AWKOPTS="-W interactive"
fi

if [ "$1" = -x ]
then
	shift
	PAT="$1"
	awk $AWKOPTS " /$PAT/ { exit } "' { print $0'\n' } '"$AWKADD"
else
	PAT="$1"
	awk $AWKOPTS ' { print $0'\n' } '"$AWKADD /$PAT/ { exit } "
fi

# echo "AWK OVER" >&2

## Drop the rest of the stream
## By backgrounding this I hope to avoid "broken stream/pipe" errors,
## but still achieve that alternate functionality, which is,
## rather than to chop a stream at a certain point,
## to wait until a certain point in a stream is reached
## (eg. watching for particular event in a logfile).
## TODO: Note I also had to make awk interactive to achieve this, which is actually a mawk option that might cause problems on Solaris, etc.

## NEITHER OF THESE WORK!  I guess awk swallowed the remaining lines when it exitted.

## Didn't work on orion: cat > /dev/null &
## OK this variable makes this behaviour configurable, in case caller /wants/ the rest of the stream after this call is over.
## In this way toline can be used to skip a block of stdin (to the given line), and then continue reading it.
## Maybe it should be the default, but this variable can be used in case it doesn't become the default.
[ "$TOLINE_LEAVE_REST" ] || cat > /dev/null
## CONSIDER: Would it be useful to background this cat?  So the rest of the stream gets disposed of, but the process returns as soon as the line was found.

[ "$TOLINE_STREAM_REST" ] && cat

## Otherwise it just leaves it for later commands (not piped after this one) to read.

# # OUT="/dev/stdout"
# OUT="&1" ## Ha! It was saving a file with that name!  <<< TYPO
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
