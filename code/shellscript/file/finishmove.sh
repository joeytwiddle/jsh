## The problem with all these "removing duplicates" scripts is verify whether or not the file is the same actual file.
## On Unix confusions with symlinks can be resolved using realpath.
## But with mounted networked computers, and virtual filesystems, this will be harder to verify.
## Possible methods:
##  - Move file A to safe storage, or just rename it.  Then check if file B is still there
##  - Alter file A ...

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
find . -not -type d |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DEST/$DIR"
	DESTFILE="$DEST/$FILE"
	if test -e "$DESTFILE" || test -f "$DESTFILE"
	then
		if cmp "$FILE" "$DESTFILE"
		then
			# echo "Could delete $FILE since $DESTFILE is the same (but be sure it's not a symlink!)"
			# cksum "$FILE" "$DESTFILE"
			# ls -l "$FILE" "$DESTFILE"
			echo "Deleting $FILE"
			rm "$FILE"
		fi
	else
		echo "Moving $FILE"
		mv "$FILE" "$DESTFILE"
	fi
done
