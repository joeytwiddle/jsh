
## Now has external dependency: contractsymlinks

# Paranoid; sensible.
set -e

if test "$1" = "" || test "$1" = --help; then
cat << !

makebackup <dir_or_file_to_backup> <backup_storage_dir> [<backup_file_prefix>]

  will create a numbered backup (tar.gz) of the given file or directory
    in <backup_dir> each time it is run.

  It also automatically generates a patch for each new version, which is
    a space-efficient way to keep a record (you may remove all but one of
    the full backups).

  The patches can be used to roll back or forwards from any full backup.
    (They are generated using diff -r -u -N -a which supports new/removed files
    and binary files.)

  Note: Although the backup files are pure, the diffs cannot contain symlinks,
    so for recovery you must run contractsymlinks before you patch -p0, and
    expandsymlinks afterwards.

  Bugs: empty directories and empty files are sometimes left floating,
    and GNU diff does not appear to support filenames with spaces!
    (The data is kept, but it gets name wrong.)

!
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

echo "Backing up $TOBACKUP into $BACKUPDIR/$BACKUPNAME-$VER.tar.gz"
cd "$DIRNAME"
tar cfz "$BACKUPDIR/$BACKUPNAME-$VER.tar.gz" "$BASENAME"

if test ! "$VER" = 0
then

	OURTMPDIR=`jgettmpdir makebak`

	THISVERSION="$OURTMPDIR/ver$VER"
	echo "Copying $TOBACKUP to temp dir so I can prepare it for diffing" ## Note: I'm fairly confident we could do this to the dir directly, provided we expandsymlinks again afterwards.  If we're backing up a file then there's really little point in this!
	mkdir -p "$THISVERSION"
	if test "$THISVERSION" = ""; then echo "Problem with THISVERSION = >$THISVERSION<"; exit 1; fi
	cd "$DIRNAME"
	cp -a "$BASENAME" "$THISVERSION"

	# Fix symlink problems by removing them!
	# but list them to a file so their changes may be seen.
	echo "Moving symlinks into .symlinks.list"
	cd "$THISVERSION" &&
	if test "`pwd`" = "$THISVERSION"
	then
		if test -d "$BASENAME"
		then
			cd "$BASENAME"
			contractsymlinks
		fi
	else echo "Problem: `pwd` != $THISVERSION"
	fi

	## We can no longer be paranoid, because expr and diff will often return 0!
	set +e
	PREVER=`expr $VER - 1` ## Exits with 0 if VER=1
	set -e

	LASTVERSION="$OURTMPDIR/ver$PREVER"
	mkdir -p "$LASTVERSION"

	echo "Extracting previous version into tempdir for comparison"
	cd "$LASTVERSION"
	tar xfz "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz"
	echo "Contracting symlinks into .symlinks.list"
	if test -d "$BASENAME"
	then
		cd "$BASENAME"
		contractsymlinks
	fi

	echo "Comparing versions, saving patch in $BACKUPDIR/$BACKUPNAME-$VER.diff"
	cd "$LASTVERSION"
	set +e
	diff -r -u -N -a "$BASENAME" "../ver$VER/$BASENAME" > "$BACKUPDIR/$BACKUPNAME-$VER.diff"
	set -e
	gzip "$BACKUPDIR/$BACKUPNAME-$VER.diff"

	# rm "$BACKUPDIR/$BACKUPNAME-$PREVER.tar.gz" ## Let's wait till we have the next version tarred up shall we?!

	cd /tmp # anywhere should do
	jdeltmp "$OURTMPDIR"

fi
