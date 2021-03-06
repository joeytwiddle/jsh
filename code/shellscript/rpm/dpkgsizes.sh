#!/bin/sh
# Apparently this can be achieved with dlocate, or dpkg-query ... ?
# noop > totals.txt

printf "" > $JPATH/logs/pkgdfiles.txt ## clear it, will be >>d into by dpkgsize

env COLUMNS=900 dpkg -l |
drop 5 | takecols 2 |
while read X
do
	dpkgsize "$X"
	if test ! "$?" = 0; then
		echo "dpkgsizes: error on $X" > /dev/stderr
	fi
done | tee $JPATH/logs/dpkgsizes.txt

gzip "$JPATH/logs/pkgdfiles.txt"
mv "$JPATH/logs/pkgdfiles.txt.gz" "$JPATH/logs/pkgdfiles-`geekdate`.txt.gz"
