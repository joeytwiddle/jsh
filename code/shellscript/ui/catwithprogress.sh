#!/bin/sh
## If the time is spent reading (piping/processing) the stream (as opposed to creating it), then this cat will show progress.
## This script assumes dd blocks.  Fortunately it does, although there may be buffers which offset the info :/ .
## If the input is from a stream (as opposed to file(s)), and -size is not specified, then this script saves a temporary copy of the stream contents, so don't use it if the stream is very long or unbounded.
## If the full contents of the stream is too large, this script is not suitable, since it must temporarily save the stream contents in a file.

## See also: pv

## TODO: Would better be wrapped in: do_this_command_line_with_output_progressbar

# jsh-depends: cursebold cursenorm filesize awksum countbytes datediff jdeltmp jgettmp striptermchars
# jsh-ext-depends: sed seq dd cat

## TODO: add option -byline, so progress is measured by line-progress through stream, rather than byte-progress.

## TODO: bug when compilejshscript was used on catwithprogress: did not recognise dd as an external dependency (probably filename too small)

# TO_XTTITLE=1

## DONE: added ETA.
## CONSIDER: separate progress code from catwith code.

## DONE: To make it properly like cat, should check args for input files.
##       If they exist, we should perform filesize on them.

## If user doesn't want to see progress, they can set this.  We do a normal cat, then drop out.
## FIXED: But it isn't as efficient as cat, because if size is not passed in above, a cat > a file is performed.  Not any more!
if [ "$NOPROGRESS" ]
then
	if [ "$1" = -size ]
	then shift; shift
	fi
	cat "$@"
	# cat $TMPFILE
	exit
fi

if [ "$1" = -size ]
then
	SIZE="$2"; shift; shift
	TMPFILE=
	# cat "$@"
## jsh-help: NOTE: If -size is passed, then the input _should_not_be_files!  (Or we could make this an "if [ ! "$SIZE" ] &&" instead of an "elif".)
elif [ "$1" ]
then
	SIZE=`
		for FILE
		do filesize "$FILE"
		done |
		awksum
	`
	TMPFILE="$*"
	PRESERVE_TMPFILE=true
	## because it _isn't_ actually a tempfile!!
	# cat "$@"
else
	TMPFILE=`jgettmp catwithprogress`
	cat > "$TMPFILE" || exit 123
	SIZE=`filesize "$TMPFILE"`
	# cat "$TMPFILE"
fi

# CURSEMESSAGECOL=`cursemagenta`
CURSEMESSAGECOL=`cursenorm;cursebold`
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
( cat $TMPFILE || exit ) | ## This causes correct error exit if input files do not exist
# exec <&1

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
		[ "$SOFAR" -gt "$SIZE" ] && SIZE="$SOFAR"
		## But I think we fill up a buffer pretty quick before we start blocking sufficiently to truly ETA.  So I remove the size of this buffer from the calculation of progress.
		SOFARRESERVED=`expr "$SOFAR" - 65536`
		[ "$SOFARRESERVED" -lt 0 ] && SOFARRESERVED=0
		[ "$SIZE" = 0 ] && SIZE=1
		PERCENTAGE=`expr 100 '*' $SOFAR / $SIZE` ## otherwise could do $SOFARRESERVED / ($SIZE - 4096)

		# BUG: If I remove this, it breaks!  Something is a bit broken somewhere.
		#      Hmm but it seems to work fine with apt-list
		#      I believe I was experiencing the bug when piping `tar c | catwithprogress | gzip -c > file.tgz`
		#echo "[log] PERCENTAGE: $PERCENTAGE"
		## Hmmm it also seems to me that N slow-running |s _after_ the call to catwithprogress means N times this many buffers.

		# if [ "$SOFAR" -gt 0 ]
		if [ "$PERCENTAGE" -gt 5 ] && [ "$SOFARRESERVED" -gt 0 ]
		then
			TIMENOW=`date +"%s"`
			TIMETAKEN=`expr "$TIMENOW" - "$STARTTIME"`
			# ESTTOTTIME=`expr "$TIMETAKEN" '*' "$SIZE" / "$SOFARRESERVED"`
			ESTTOTTIME=`expr "$TIMETAKEN" '*' '(' "$SIZE" - 65536 ')' / "$SOFARRESERVED"`
			ESTREMTIME=`expr "$ESTTOTTIME" - "$TIMETAKEN"`
			# ETAMSG="   ETA: $ESTREMTIME seconds"
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
		# printf "\r%s" "$CURSEMESSAGECOL$STATE $SOFAR/$SIZE ($PERCENTAGE%)$ETAMSG $CURSENORM" >&2
		## Added clearing of string, which is better than overwriting, because sometimes the length gets much smaller!
		STRINGTOPRINT="$CURSEMESSAGECOL$STATE $SOFAR/$SIZE ($PERCENTAGE%)$ETAMSG $CURSENORM"
		if [ "$LASTPRINTLENGTH" ]
		then
			# CLEARANCE=`seq 1 "$LASTPRINTLENGTH" | while read N; do echo -n " "; done`
			CLEARANCE=`seq 1 "$LASTPRINTLENGTH" | sed 's+.*++' | tr '\n' ' '`
			# printf "\r%s" "$CLEARANCE" >&2
		fi

		if [ "$TO_XTTITLE" ]
		then
			## There were problems with jsh's printf implementation of xttitle.
			## Stdout was busy, stderr caused nasty flashes :P
			# xttitle "$STRINGTOPRINT"
			xttitle "$STRINGTOPRINT"
		else
			printf "\r%s\r%s" "$CLEARANCE" "$STRINGTOPRINT" >&2
			LASTPRINTLENGTH=`
				printf "\r%s" "$STRINGTOPRINT" | striptermchars | wc -c
			`
			# printf "\r%s" "$CURSEMESSAGECOL$STATE [+$ADDED/$BLOCKSIZE] $SOFAR/$SIZE ($PERCENTAGE%)$ETAMSG $CURSENORM" >&2
			# +$ADDED/$BLOCKSIZE 
		fi

		## CONSIDER: should really count length of printed string
		##           (either printed length, or blank string including irrelevant colours)
		##           so it can ^H (backspace) over them to cleanup, or print that many spaces to blank them on next run

	# fi

	SOFAR=`expr $SOFAR + $ADDED`

	grep "^0+0" "$DDTMPFILE" >/dev/null && break

done

RESULT="$?" ## This causes correct error-exit if catwithprogress is killed (e.g. Ctrl+C-ed).

echo >&2 ## Or clear the line and \r

[ "$PRESERVE_TMPFILE" ] || ( [ "$TMPFILE" ] && jdeltmp "$TMPFILE" )
jdeltmp "$DDTMPFILE"

exit "$RESULT"
