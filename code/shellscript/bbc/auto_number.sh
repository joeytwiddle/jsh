## BUG TODO: '\'s get swallowed!  '\\'s probably get converted to '\'s.
## TODO: REM lines tend to get their spaces squeezed.  This is not really desirable.
## TODO: Renumbering can break GOTO and GOSUB calls.  We should warn when they are present!  Or we could try to fix them...
## TODO: Rename this script "bbcbasicrenumber", or factor out the common (non-BBC) stuff, and split into two scripts...

if [ "$1" = -numall ]
then shift ; NUMBER_ALL=true
fi

if [ "$1" = -run ]
then shift ; RUN=true
fi

## No opt but can be provided:
# FAST=true

# LINENUM=10000
# LINENUM=10000
# LINENUM=00001 ## pretty-printing pre-padding with '0's is lost!
# LINENUM=10001
LINENUM=10010
DELTANUM=10
## I want to save space!
LINENUM=1
DELTANUM=1

[ "$FAST" ] && echo 'MODE 7 : PRINT "Loading '"$*"'" : VDU 21'

cat "$@" |

## First of all, mark all lines where we will want a line number - place a '.' at the start.
if [ "$NUMBER_ALL" ]
then
	# sed 's+.*+. \0+' ## Add .s to all lines
	sed 's/^\([ ]*[[:digit:]][[:digit:]]*\( \|\)\|^\)/./' ## Add '.' to each line, stripping numbers from any lines which have them.
else sed 's/^[ ]*[[:digit:]][[:digit:]]*\( \|\)/./' ## Add '.' to each line with a line number, and strip the line number.
fi |

## Now add a line number to EVERY line!
while read LINE
do
	## BUG TODO: \\s here will come out as \s
	# echo "  $LINENUM $LINE"
	echo "$LINENUM $LINE"
	# LINENUM=`expr "$LINENUM" + 20`
	# LINENUM=`expr "$LINENUM" + 1`
	LINENUM=`expr "$LINENUM" + $DELTANUM`
done |

## Now remove unwanted line numbers - when no '.' is present:
sed 's/^[ ]*[[:digit:]][[:digit:]]* \($\|[^.]\)/\1/' | ## Drop lines with line number but no '.'  (Aka drop line numbers when not wanted - no '.' was present.)

## And finally remove the '.' markers, now we are finished with them.
sed 's/^\([ ]*[[:digit:]][[:digit:]]* \)\./\1/' | ## Drop '.' from every line with '.' (cleanup, leave just the line number, or nothing).
# sed 's/^\([ ]*[[:digit:]][[:digit:]]*\) $/\1/' |

cat

if [ "$FAST" ]
then
	echo 'VDU 6'
	echo ': padding'
	echo ': padding'
	echo ': padding'
	echo ': padding'
	echo ''
	echo 'VDU 6 : MODE 7 : PRINT "Running..."'
	echo ''
fi

[ "$RUN" ] && echo 'RUN'

