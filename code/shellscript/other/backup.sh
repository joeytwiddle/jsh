# Want a safe tar, that does not copy:
# higher directories (.*), symbolic links, executables, zips

date >> /home/joey/j/log/cron.txt
echo Starting routine backup >> /home/joey/j/log/cron.txt
wall Hwi is performing a routine backup

# echo $PATH
alias rm='/bin/rm -f'

# Copy current backups into old and clear ready for new
mkdir -p /mnt/stig/backups/
mkdir -p /mnt/stig/oldbackups/
cp -rf /mnt/stig/backups/* /mnt/stig/oldbackups
# echo A
rm -r /mnt/stig/backups/*
# echo B

# Joey's ~ directory (.* files and stuff...)
# We get a weird error if the zip goes at the bottom, after the
# slightly dodgy safetar etc ... !
# cd /home/joey/
zip -q /mnt/stig/backups/twiddle `find /home/joey -size 0 -o -size 1 -o -size 2 -o -size 3 -o -size 4 -o -size 5 -o -size 6 -o -size 7 -o -size 8 -o -size 9 -maxdepth 1`
# zip -q /mnt/stig/backups/twiddle .* *

# Joeylib, JLib, C, Java sources
makeport
# cp /home/joey/j/out/hwiport.tgz /mnt/stig/backups/

# Website
safetar /stuff/portablelinux/var/www hwihtml
safetar /stuff/portablelinux/usr/share/java/servlets servlets

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
wall Backup complete

( echo
	date
	cvsdiffs
) >> $JPATH/logs/cvsdiffs.txt
