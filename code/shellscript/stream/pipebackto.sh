## Convenient way to change the contents of a file using a single pipe.
##
## Eg., to avoid:
##
##   cat $FILE | ... process ... > $FILE
##
## from emptying the file before reading it, use:
##
##   cat $FILE | ... process ... | pipebackto $FILE
##
## Could alternatively be called: catback, catlater, ...

## So that if "$@" = "", then 'cat "$@" | ... | pipebackto "$@"' will work over stdin/out, as in eg. replaceline.
## Note: this feature may not stay.  CONSIDER: what about cat - | ... | pipebackto - ?
if [ ! "$*" ]
then cat; exit
fi

if [ "$1" = -bak ]
then
	shift
	FILE="$1"
	cp "$FILE" "$FILE".b4pb
fi

FILE="$1"

TMPFILE=`jgettmp $0`

cat > $TMPFILE

## That should finish way after the initial cat has opened filehandle, so we can:

cat $TMPFILE > "$FILE"

jdeltmp $TMPFILE
