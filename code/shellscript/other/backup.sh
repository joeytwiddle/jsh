# Want a safe tar, that does not copy:
# higher directories (.*), symbolic links, executables, zips

export OLDDESTDIR=/mnt/stig/oldbackups
export DESTDIR=/mnt/stig/backups

safetar() {
	echo "Compressing \"$1\" into \"$2\""
	# cd $1
	# /bin/tar cfz "$DESTDIR"/$2.tgz *
	tar cfz "$DESTDIR"/$2.tgz "$1"
}

date >> $JPATH/logs/cron-backup.txt
echo Starting routine backup >> $JPATH/logs/cron-backup.txt
## echo Hwi is performing a routine backup | wall

# echo $PATH

# Copy current backups into old and clear ready for new
mkdir -p "$DESTDIR"/
mkdir -p "$OLDDESTDIR"/
mv -f "$DESTDIR"/* "$OLDDESTDIR"

# Joey's ~ directory (.* files and stuff...)
# We get a weird error if the zip goes at the bottom, after the
# slightly dodgy safetar etc ... !
# zip -q "$DESTDIR"/twiddle `find /home/joey/debian/ -type f -size 0 -o -size 1 -o -size 2 -o -size 3 -o -size 4 -o -size 5 -o -size 6 -o -size 7 -o -size 8 -o -size 9 -maxdepth 2`
# zip -q "$DESTDIR"/twiddle .* *
cd /home/joey/
cp private.tgz.encrypted "$DESTDIR" ||
cp private.tgz.encrypted.old "$DESTDIR" ||
cp private.tgz.encrypted.bak "$DESTDIR"
# zip -q -r "$DESTDIR"/twiddle debian/.gnupg debian/.wine* debian/.mutt debian/Mail debian/.vmware
## I have no idea why I need to touch it!
touch "$DESTDIR"/twiddle.tgz
tar cfz "$DESTDIR"/twiddle.tgz debian/.gnupg debian/.wine* debian/Mail debian/.vmware j/org j/music j/logs/debpkgs-list-today.log

## Now all in CVS.
# Joeylib, JLib, C, Java sources
# makeport
# cp /home/joey/j/out/hwiport.tgz "$DESTDIR"/

# Website
safetar /var/www/ hwihtml
safetar /usr/share/java/servlets/ servlets

# Organiser
safetar /home/joey/j/org/ org
# Tools go with makeport
# safetar /home/joey/j/code/shellscript shellscript

# /etc
safetar /etc/ etc
#safetar /home/joey/ twiddle

# Submit revision changes
# revisionchanges

echo Done
## echo Backup complete | wall

( echo
	date
	cvsdiffs
) > $JPATH/logs/cvsdiffs.txt
