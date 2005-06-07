## If the time is spent reading the stream (not creating it), then this cat will show progress.
## This script assumes dd blocks.  Fortunately it does!
## This script saves a temporary copy of the stream contents, so don't use it if the stream is very long or unbounded.
## If the full contents of the stream is too large, this script is not suitable, since it must temporarily save the stream contents in a file.
## Hmm well it works over networks at least, maybe helped if stdout/err are sent in sync over ssh.
## But it doesn't always work.

## TODO: add ETA.  CONSIDER: factoring out progress from catwith first.

## TODO: To make it properly like cat, should check args for input files.
##       If they exist, we should perform filesize on them.

if [ "$1" = -size ]
then
	SIZE="$2"; shift; shift
	TMPFILE=
else
	TMPFILE=`jgettmp catwithprogress`
	cat "$@" > "$TMPFILE" || exit 123
	SIZE=`filesize "$TMPFILE"`
fi

## If user doesn't want to see progress, they can set this.  We do a normal cat, then drop out.
## But it isn't as efficient as cat, because if size is not passed in above, a cat > a file is performed.
if [ "$NOPROGRESS" ]
then
	cat $TMPFILE
	exit
fi

# CURSEMESSAGECOL=`cursemagenta`
CURSEMESSAGECOL=`cursewhite;cursebold`
CURSENORM=`cursenorm`

DDTMPFILE=`jgettmp catwithprogress_dderr`

## Of course the actual desired BLOCKSIZE is whatever returns us from dd about once every second (so display will update that often).
## But we won't know this until we've started, _and_ all the buffers are full.
BLOCKSIZE=`expr "$SIZE" / 50`
# BLOCKSIZE=`expr "$SIZE" / 500`
# BLOCKSIZE=`expr "$SIZE" / 1000 '*' 2` ## ensures even
[ "$BLOCKSIZE" ] || BLOCKSIZE=1024
[ "$BLOCKSIZE" -gt 0 ] || BLOCKSIZE=1 ## Well if size is valid, maybe this should be 1.
# [ "$BLOCKSIZE" -lt 10240000 ] || BLOCKSIZE=10240000
# BLOCKSIZE=4096
# jshinfo "$BLOCKSIZE"

SOFAR=0

STARTTIME=`date +"%s"`

# if [ "$TMPFILE" ]
# then cat "$TMPFILE"
# else cat
# fi |
cat $TMPFILE |

while true
do

	# dd bs=1 count="$BLOCKSIZE" 2> "$DDTMPFILE"
	dd bs="$BLOCKSIZE" count=1 2> "$DDTMPFILE"
	# nice -n 5 dd bs="$BLOCKSIZE" count=1 2> "$DDTMPFILE"
	# if cat "$DDTMPFILE" | grep "^1+0 records in" >/dev/null
	# if cat "$DDTMPFILE" | grep "^0 bytes transferred" >/dev/null
	# then verbosely sleep 1
	# fi

	# ADDED=`cat "$DDTMPFILE" | tail -n 1 | sed 's+ .*++'`
	ADDED=`tail -n 1 "$DDTMPFILE" | sed 's+ .*++'`

	# if [ "$ADDED" = 0 ]
	# then verbosely sleep 1
	# else
	# if [ ! "$ADDED" -lt "$BLOCKSIZE" ]
	# then

		# SOFAR=`expr $SOFAR + $BLOCKSIZE`
		SOFAR=`expr $SOFAR + $ADDED`
		[ "$SOFAR" -gt "$SIZE" ] && SIZE="$SOFAR"
		## But I think we fill up a buffer pretty quick before we start blocking sufficiently to truly ETA.  So I remove the size of this buffer from the calculation of progress.
		SOFARRESERVED=`expr "$SOFAR" - 4096`
		[ "$SOFARRESERVED" -lt 0 ] && SOFARRESERVED=0
		[ "$SIZE" = 0 ] && SIZE=1
		PERCENTAGE=`expr 100 '*' $SOFAR / $SIZE` ## otherwise could do $SOFARRESERVED / ($SIZE - 4096)
		## Hmmm it also seems to me that N slow-running |s _after_ the call to catwithprogress means N times this many buffers.

		# if [ "$SOFAR" -gt 0 ]
		if [ "$PERCENTAGE" -gt 5 ] && [ "$SOFARRESERVED" -gt 0 ]
		then
			TIMENOW=`date +"%s"`
			TIMETAKEN=`expr "$TIMENOW" - "$STARTTIME"`
			ESTTOTTIME=`expr "$TIMETAKEN" '*' "$SIZE" / "$SOFARRESERVED"`
			ESTREMTIME=`expr "$ESTTOTTIME" - "$TIMETAKEN"`
			# ETAMSG="   ETA: $ESTREMTIME seconds ("`date -d "$ESTREMTIME seconds"`")"
			# ETAMSG="   ETA: `datediff -english $ESTREMTIME` ("`date -d "$ESTREMTIME seconds"`")"
			ETAMSG=" ETA: `datediff -english $ESTREMTIME`" ## Trailing space since datediff's output was not fixed-length
		fi

		if [ "$ADDED" = "$BLOCKSIZE" ]
		then STATE=">" # ; BLOCKSIZE=`expr "$BLOCKSIZE" '*' 2`
		else STATE="." # ; [ "$BLOCKSIZE" -gt 2 ] && BLOCKSIZE=`expr "$BLOCKSIZE" / 2` # BLOCKSIZE=1
		fi

		# echo "$SOFAR / $SIZE ($PERCENTAGE%)" >&2
		# printf "%s\r" "$SOFAR / $SIZE ($PERCENTAGE%)$ETAMSG" >&2
		printf "\r%s" "$CURSEMESSAGECOL$STATE $SOFAR/$SIZE ($PERCENTAGE%)$ETAMSG $CURSENORM" >&2
		# printf "\r%s" "$CURSEMESSAGECOL$STATE [+$ADDED/$BLOCKSIZE] $SOFAR/$SIZE ($PERCENTAGE%)$ETAMSG $CURSENORM" >&2
		# +$ADDED/$BLOCKSIZE 

		## CONSIDER: should really count length of printed string
		##           (either printed length, or blank string including irrelevant colours)
		##           so it can ^H (backspace) over them to cleanup, or print that many spaces to blank them on next run

	# fi

	grep "^0+0" "$DDTMPFILE" >/dev/null && break

done

echo >&2 ## Or clear the line and \r

[ "$TMPFILE" ] && jdeltmp "$TMPFILE"
jdeltmp "$DDTMPFILE"
