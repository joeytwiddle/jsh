find "/stuff/software/demoz/recommend/" -type f |
grep "/wine/" |
# Optional:
grep -v "/gl/" |
randomorder |
while read X; do

	echo "$X"

	`jwhich xterm` -geometry 80x25+0+0 -fg white -bg black -e wineonedemo "$X"
	# wineonedemo "$X"

done
