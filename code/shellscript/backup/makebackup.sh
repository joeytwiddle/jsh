## TODO: symlinks causing unwanted loops are not caught by diff :-(
##       need to tar up files only and then diff extracted tars!

if test "$1" = ""; then
	echo "makebackup <dir/file> <backup_dir> [ <backup_prefix> ]"
	exit 1
fi

TOBACKUP="$1"
BACKUPDIR="$2"
DIRNAME=`dirname "$TOBACKUP"`
BASENAME=`basename "$TOBACKUP"`
test "$3" &&
BACKUPNAME="$3" ||
BACKUPNAME="$BASENAME"

mkdir -p "$BACKUPDIR" || exit 1

CREATEDIR=`jgettmpdir makebak-create`
cd "$DIRNAME"
cp -a "$BASENAME" "$CREATEDIR"
cd "$CREATEDIR" || exit 1
find . -type l |
while read X
do
	rm "$X"
done

VER=1
while test -f "$BACKUPDIR/$BACKUPNAME-$VER.diff.gz" || test -f "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz"; do
	VER=`expr $VER + 1`
done

if test ! "$VER" = 1; then

	PREVER=`expr $VER - 1`

	EXTRACTDIR=`jgettmpdir makebak-extract`

	cd "$EXTRACTDIR"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"

	diff -r "$EXTRACTDIR/$BASENAME" "$CREATEDIR/$BASENAME" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	jdeltmp "$EXTRACTDIR"

fi

tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"

