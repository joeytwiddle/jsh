# Apparently this can be achieved with dlocate, or dpkg-query ... ?
# noop > totals.txt
noop > $JPATH/logs/pkgdfiles.txt
env COLUMNS=184 dpkg -l | drop 5 | takecols 2 | while read X; do
        dpkgsize "$X"
done
