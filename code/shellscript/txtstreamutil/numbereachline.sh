N=0
escapeslash | ## since echo "$LINE" will lose \s if not doubled.  BUG: what else might echo "$LINE" lose?
while read LINE
do
	printf "%s\n" "$N	$LINE"
	# printf "%03i\t%s\n" "$N" "$LINE"
	N=$(($N+1))
done
