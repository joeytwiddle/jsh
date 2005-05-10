if [ "$1" = --help ]
then
cat << !

"| dog \$FILE" and "| pipebackto \$FILE" are alternatives to "> \$FILE".

Let's you write back to a file in a single pipe:

    cat \$FILE | ... <process> ... | dog \$FILE

  (Because all good shell users know that this doesn't work:

    cat \$FILE | ... process ... > \$FILE

  It empties the file before reading it!)

Or, let's you change a file atomically:

    ... <slow_process_to_create_file> ... | pipebackto \$FILE

The file will not be overwritten until the process has completed.
Hence, no other processes will see the partial file.  :)

!
exit 1
fi

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
