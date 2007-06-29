SRC="$1"
DEST="$2"

if [ ! "$SRC" ] || [ ! "$DEST" ]
then
	echo "copyusingtar <source_dir> <dest_dir>"
	exit 1
fi

( cd "$SRC" ; tar c . ) |
( cd "$DEST" ; tar x )
