echo `dlocate -du "$@" | grep total | takecols 1`"	$@"
exit 0

#############################################

# My version, much slower but robust to missing files
## I had problems with unwanted printing of file lists after the size list but maybe that problem is elsewhere
# FILES=`dpkg -L "$@" | while read Y; do
FILES=`dlocate -L "$@" | while read Y; do
        if test -f "$Y"; then
                echo "$Y"
        fi
done`
if test "$FILES" = ""; then
	echo "0	$@"
else
	echo "$FILES" >> $JPATH/logs/pkgdfiles.txt
	DUSK=`du -sk $FILES`
	# echo "$DUSK" > files-"$@".txt
	PKGSIZE=`echo "$DUSK" | takecols 1 | awksum`
	printf "$PKGSIZE\t$@\n" # >> totals.txt
fi
