# Apparently this can be achieved with dlocate, or dpkg-query ... ?
# noop > totals.txt
env COLUMNS=184 dpkg -l |
drop 5 | takecols 2 |
while read X
do
	dpkgsize "$X"
	if test ! "$?" = 0; then
		echo "dpkgsizes: error on $X" > /dev/stderr
	fi
done | tee $JPATH/logs/pkgdfiles.txt
