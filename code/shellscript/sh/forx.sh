LIST=""
while test ! "x$2" = "x"; do
	LIST=$LIST" ""$1"
	shift
done

for X in $LIST; do
	$1 "$X"
done
