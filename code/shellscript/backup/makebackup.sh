## DONE: symlinks causing unwanted loops are not caught by diff :-(
##       need to tar up files only and then diff extracted tars!
## TODO: Nope, we should tar up everything,
##       then untar current and previous, strip links, then diff.
##       No, rather than strip them, we should turn them into a file which can be diffed, and from which they can be recreated.
##       Would a plain tar do this?

## Now has external dependency: contractsymlinks

## Turns out I needed diff -r -u before patch -p0 would work.
## But it still doesn't deal with binary files well, and missing files are just skipped!
##                                                       ok that should be fixed by using -N, but it ain't
##                                                       alternatively -P is forward-only

## Actually it seems to work but not for binary files.  Trying -a.

## Wahoo got it!!

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

if test ! "$VER" = 0
then

	CREATEDIR="$OURTMPDIR/ver$VER"
	echo "Copying $TOBACKUP to $CREATEDIR"
	mkdir -p "$CREATEDIR"
	if test "$CREATEDIR" = ""; then echo "Problem with CREATEDIR = >$CREATEDIR<"; exit 1; fi
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

	## We can no longer be paranoid, because expr and diff will often return 0!
	set +e
	PREVER=`expr $VER - 1` ## Exits with 0 if 

	EXTRACTDIR="$OURTMPDIR/ver$PREVER"
	mkdir -p "$EXTRACTDIR"

	echo "Extracting previous copy into $EXTRACTDIR"
	cd "$EXTRACTDIR"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	cd "$EXTRACTDIR/$BASENAME"
	echo "Contracting symlinks"
	contractsymlinks

	echo "Comparing against previous copy, storing diff in $BACKUPDIR/$BACKUPNAME-$VER.diff"
	cd "$EXTRACTDIR"
	diff -r -u -N -a "$BASENAME" "../ver$VER/$BASENAME" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	# rm "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"

fi

echo "Backing up $TOBACKUP into $BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
cd "$DIRNAME"
## Or to make a backup with the symlinks:
tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"

cd /tmp # anywhere should do
jdeltmp "$OURTMPDIR"
