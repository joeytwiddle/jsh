# Lists most recent date of access to files of
# each package on a Debian system.

dpkg -l | drop 5 | sed "s/[^ ]* //" |
while read PKG VER REST; do
	FILES=` dlocate -L "$PKG" |
		# grep "(/bin/|/lib/)"
		cat
	`
	LAST=`
		dar -d $FILES |
		grep -v "/$" | grep -v " -> " |
		takecols 6 7 | trimempty | tail -1
	`
	printf "$PKG\t$LAST\t$REST\n"
done
