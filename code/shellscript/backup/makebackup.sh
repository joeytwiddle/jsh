## TODO: symlinks causing unwanted loops are not caught by diff :-(
##       need to tar up files only and then diff extracted tars!

# Paranoid; sensible.
set -e

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

# Fix symlink problems by removing them!
# but list them to a file so their changes may be seen.
cd "$CREATEDIR" &&
if test `pwd` = "$CREATEDIR"; then
	if test -d "$TOBACKUP"
	then
		find . -type l |
		while read X
		do
			'ls' -ld "$X" # | sed 's/[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*//' | sed 's/ -> /	->	/'
			### I AM A BIT SCARED OF THIS LINE
			## (eg. it deleted some of my symlinks when jgettmpdir wasn't working properly => CREATEDIR=""!)
			rm "$X"
		done |
		sed 's| -> |	->	|' |
		sed 's|.* \([^ 	]*	->	.*\)|\1|' > "$BASENAME/.symlinks.list"
	fi
else
	echo "Problem: "`pwd`" != $CREATEDIR"
fi

VER=1
while test -f "$BACKUPDIR/$BACKUPNAME-$VER.diff.gz" || test -f "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz"; do
	VER=`expr $VER + 1`
done

if test ! "$VER" = 1; then

	PREVER=`expr $VER - 1`

	EXTRACTDIR=`jgettmpdir makebak-extract`

	cd "$EXTRACTDIR"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"

	# Unparanoid, because we want diff to return 1!
	set +e
	diff -r "$EXTRACTDIR/$BASENAME" "$CREATEDIR/$BASENAME" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	# rm "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	jdeltmp "$EXTRACTDIR"

fi

# tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"
cd "$CREATEDIR"
tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"

cd /tmp # anywhere should do
jdeltmp "$CREATEDIR"
