find "$PWD" -type f |
grep "/wine/" |
# Optional:
grep -v "/gl/" |
randomorder |
while read X; do

	echo "$X"

	cp ./wineone.sh /tmp
	`jwhich xterm` -fg white -bg black -e /tmp/wineone.sh "$X"
	# /tmp/wineone.sh "$X"

done
