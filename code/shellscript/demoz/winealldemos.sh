find "$PWD" -type f |
grep "/wine/" |
# Optional:
grep -v "/gl/" |
randomorder |
while read X; do

	echo "$X"

	`jwhich xterm` -fg white -bg black -e wineonedemo "$X"
	# wineonedemo "$X"

done
