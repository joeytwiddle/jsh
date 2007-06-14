PKGNAME="$1"
VERSION=`apt-list -installed pkg "$PKGNAME" | head -n 1 | takecols 2`
if [ "$VERSION" ]
then
	VERSION_EXPR=`echo "$VERSION" | sed 's/+/\\+/g'`
	SIZE=`
		apt-cache show "$PKGNAME" |
		# fromline "Version: $VERSION_EXPR" | grep "^Size:" | head -n 1 |
		toline "Version: $VERSION_EXPR" | grep "^Installed-Size:" | tail -n 1 |
		takecols 2
	`
fi
[ "$SIZE" ] || SIZE=-1

echo "$SIZE	$PKGNAME $VERSION"
exit

if which dlocate > /dev/null 2>&1
then
	echo `
		dlocate -du "$@" |
		prepend_each_line "$*:	" | tee -a "$JPATH/logs/pkgdfiles.txt" | dropcols 1 | ## optionally save the filenames
		grep total | takecols 1`"	$@"
	exit
fi

#############################################

# My version, much slower but robust to missing files
## I had problems with unwanted printing of file lists after the size list but maybe that problem is elsewhere
# FILES=`dlocate -L "$@" | while read Y; do
## TODO: the list which is saved should include non-files; the du should include symlinks (but obviously not directories)
FILES=`dpkg-L "$@" | while read Y; do
        if test -f "$Y"; then
                echo "$Y"
        fi
done`
if test "$FILES" = ""; then
	echo "0	$@"
else
	echo "$FILES" | prepend_each_line "$*:	" >> $JPATH/logs/pkgdfiles.txt ## optionally save the filenames
	DUSK=`du -sk $FILES`
	# echo "$DUSK" > files-"$@".txt
	PKGSIZE=`echo "$DUSK" | takecols 1 | awksum`
	printf "$PKGSIZE\t$@\n" # >> totals.txt
fi
