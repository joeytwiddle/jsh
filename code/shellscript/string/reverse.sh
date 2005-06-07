## NOTE BUG: inefficient on long lists
# LIST=""
# while read X; do
	# LIST="$X
# $LIST"
# done
# printf "$LIST"

## More efficient version; use sort to do reversal for us!
## jsh-ext-depends: sort
N=0
while read LINE
do
	echo "$N $LINE"
	N=`expr "$N" + 1`
done |
sort -n -k 1 -r |
dropcols 1
