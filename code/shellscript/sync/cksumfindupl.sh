# cksumall $* > tmp.txt

cat tmp.txt | grep -v "/CVS/" | grep -v "\.b4sr$" > tmp2.txt
mv tmp2.txt tmp.txt

cat tmp.txt | while read X; do
	KEY=`echo $X | sed "s/ \..*//"`
	RES=`grep "$KEY" tmp.txt`
	if test "$RES" = "$X"; then
		noop
	else
		echo "------------------"
		echo "$RES"
		# cmp $RES   returns 0 if they really are duplicates =)
	fi
done
