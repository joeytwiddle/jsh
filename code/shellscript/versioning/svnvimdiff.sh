FILENAME="$1"

REVISION="$2"
if [ "$REVISION" ]
then EXTRAARGS="-r $REVISION"
fi

## Get a copy of the repository version by reversing current diff against repository:
TMPFILE=`jgettmp "$1.repository"`
cp "$FILENAME" $TMPFILE
svn diff $EXTRAARGS "$FILENAME" | patch -R $TMPFILE || exit 1

vimdiff $TMPFILE "$FILENAME"

jdeltmp $TMPFILE
