if [ "$PADDING" ]
then PADSTR="%0$PADDING"i
else PADSTR="%03i"
fi

N=0
escapeslash | ## since echo "$LINE" will lose \s if not doubled.  BUG: what else might echo "$LINE" lose?
while read LINE
do
	# printf "%s\n" "$N	$LINE"
	printf "$PADSTR\t%s\n" "$N" "$LINE"
	N=$(($N+1))
done
