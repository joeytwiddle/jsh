if test "$1" = ""; then
	echo "makebackup <dir/file> <backup_dir> [ <backup_prefix> ]"
	exit 1
fi

TOBACKUP="$1"
BACKUPDIR="$2"
test "$3" &&
BACKUPNAME="$3" ||
BACKUPNAME=`basename "$1"`

VER=1
while test -f "$BACKUPDIR/$BACKUPNAME-$VER.diff.gz" || test -f "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz"; do
	VER=`expr $VER + 1`
done

if test ! "$VER" = 1; then

	PREVER=`expr $VER - 1`

	EXTRACTDIR=`jgettmpdir`

	cd "$EXTRACTDIR"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"

	diff -r "$EXTRACTDIR" "$TOBACKUP" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	jdeltmp "$EXTRACTDIR"

fi

tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$TOBACKUP"

