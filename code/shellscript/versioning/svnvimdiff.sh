FILENAME="$1"

## Get a copy of the repository version by reversing current diff against repository:
TMPFILE=`jgettmp "$1.repository"`
cp "$FILENAME" $TMPFILE
svn diff "$FILENAME" | patch -R $TMPFILE || exit 1

vimdiff $TMPFILE "$FILENAME"

jdeltmp $TMPFILE
