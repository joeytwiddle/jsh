if test "$1" = "topdown" || test "$1" = "bestfirst"; then
	for X in `seq 10 -1 0`; do
		winealldemoz "/$X/"
	done
	exit 0
fi

find "/stuff/software/demoz/recommend/" -type f |
grep "/wine/" |
# Optional:
if test "$1" = ""; then
	cat
else
	grep "$1"
fi |
# grep -v "/gl/" |
# grep "/gl/" |
randomorder |
while read X; do

	echo "$X"

	`jwhich xterm` -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# wineonedemo "$X"

done
