## DONE: symlinks causing unwanted loops are not caught by diff :-(
##       need to tar up files only and then diff extracted tars!
## TODO: Nope, we should tar up everything,
##       then untar current and previous, strip links, then diff.
##       No, rather than strip them, we should turn them into a file which can be diffed, and from which they can be recreated.
##       Would a plain tar do this?

## Turns out I needed diff -r -u before patch -p0 would work.
## But it still doesn't deal with binary files well, and missing files are just skipped!
##                                                       ok dealt with using -N
##                                                       alternatively -P is forward-only

## Now has external dependency: contractsymlinks

# Paranoid; sensible.
set -e

if test "$1" = ""; then
	echo "makebackup <dir/file_to_backup> <backup_dir> [ <backup_prefix> ]"
	exit 1
fi

TOBACKUP="$1"
BACKUPDIR="$2"

DIRNAME=`dirname "$TOBACKUP" | sed "s+^\([^/]\)+$PWD/\1+"`
BASENAME=`basename "$TOBACKUP"`
test "$3" &&
BACKUPNAME="$3" ||
BACKUPNAME="$BASENAME"

mkdir -p "$BACKUPDIR" || exit 1

## Establish (from destination files) which version backup we are creating:
VER=0
while test -f "$BACKUPDIR/$BACKUPNAME-$VER.diff.gz" || test -f "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
do VER=`expr $VER + 1`
done

OURTMPDIR=`jgettmpdir makebak`
CREATEDIR="$OURTMPDIR/ver$VER"
mkdir -p "$CREATEDIR"
if test "$CREATEDIR" = ""; then echo "Problem with CREATEDIR = >$CREATEDIR<"; exit 1; fi
echo "Copying $TOBACKUP to $CREATEDIR"
cd "$DIRNAME"
cp -a "$BASENAME" "$CREATEDIR"

# Fix symlink problems by removing them!
# but list them to a file so their changes may be seen.
echo "Moving symlinks in $CREATEDIR into $BASENAME/.symlinks.list"
cd "$CREATEDIR" &&
if test "`pwd`" = "$CREATEDIR"
then
	if test -d "$BASENAME"
	then
		cd "$BASENAME"
		contractsymlinks
	fi
else echo "Problem: `pwd` != $CREATEDIR"
fi

if test ! "$VER" = 0
then

	## We can no longer be paranoid, because expr and diff will often return 0!
	set +e
	PREVER=`expr $VER - 1` ## Exits with 0 if 

	EXTRACTDIR="$OURTMPDIR/ver$PREVER"
	mkdir -p "$EXTRACTDIR"

	echo "Extracting previous copy into $EXTRACTDIR"
	cd "$EXTRACTDIR"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	cd "$EXTRACTDIR/$BASENAME"
	contractsymlinks

	echo "Comparing against previous copy, storing diff in $BACKUPDIR/$BACKUPNAME-$VER.diff"
	cd "$EXTRACTDIR"
	diff -r -u -N "$BASENAME" "../ver$VER/$BASENAME" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	# rm "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"

fi

echo "Backing up $TOBACKUP into $BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
cd "$DIRNAME"
## Or to make a backup with the symlinks:
# cd "$CREATEDIR"
tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"

cd /tmp # anywhere should do
jdeltmp "$OURTMPDIR"
