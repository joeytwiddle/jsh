if [ "$2" ]
then
	verbosely intseq "$1" 1 "$2" | chooserandomline
else
	# verbosely seq 0.0 0.01 1.0 | chooserandomline
	NUM="4.0"
	for I in 1 2 3
	do
		# DD="-"
		# [ `randomnumber 1 2` = 1 ] && DD="+"
		DD=`chooserandom - +`
		DN=`chooserandom 0.125 0.5 1.0 1.5 2.0 3.0 2.5 4.0 8.0 16.0 256.0 512.0 640.0`
		# NUM=`calc "$NUM" "$D" "$RND" '*' "$M"
		NUM=`calc "$NUM" "$DD" "$DN"`
	done
	echo "$NUM"
fi
