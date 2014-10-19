# jsh-depends: jgettmp jdeltmp
# jsh-depends-ignore: there dog write before pipe
# jsh-ext-depends-ignore: file

## See also: sponge from moreutils
## But beware that using a RAM method could result in data loss during a system crash/reset: http://mywiki.wooledge.org/BashPitfalls#pf13

## TODO: If given a file, for efficiency pipebackto should seek to obtain a tmpfile on the partition the file is on.

## TODO POLICY: I don't know what it does now, but dog should act similarly to cat, but it should offer the feature that
##              it will only start streaming out the data once it has totally finished reading in the data.  Might be useful...

if [ "$1" = --help ]
then
cat << !

"| dog \$FILE" and "| pipebackto \$FILE" are alternatives to "> \$FILE".

  1) Let's you write back to a file in a single pipe command:

       cat \$FILE | ... process ... | dog \$FILE   # good

     Because all good shell users know that this doesn't work:

       cat \$FILE | ... process ... > \$FILE       # BAD

     It empties the file before reading it!

     For more info, see: http://mywiki.wooledge.org/BashPitfalls#pf13

  2) Also, they let you change a file atomically:

       ... slow_process_to_create_file ... | pipebackto \$FILE

     The file will not be overwritten until the process has completed.
     Hence, no other processes will see the partial file.  :)

     TODO: Check: I think this means the destination will not be overwritten if the command failed (for whatever reason).
           Although if there is not enough disk-space when the dog is moved, maybe we get a partially written file?

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

TMPFILE=`jgettmp $0` || exit

cat > $TMPFILE || exit

## That should finish way after the initial cat has opened filehandle, so we can:

cat $TMPFILE > "$FILE"
ERR="$?"

jdeltmp $TMPFILE

exit "$ERR"
