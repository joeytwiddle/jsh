SRC="$1"
DEST="$2"

if test ! "$SRC" || test ! "$DEST"
then
	echo "finishmove <srcdir> <destdir>"
	echo "moves all files in srcdir to destdir"
	# echo "NB: <destdir> must be absolute!"
	exit 1
fi

SRC=`absolutepath "$SRC"`
DEST=`absolutepath "$DEST"`

cd "$SRC"
find . -type f |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DEST/$DIR"
	mv "$FILE" "$DEST/$DIR"
done
