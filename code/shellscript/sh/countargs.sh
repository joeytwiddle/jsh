N=0
while test ! "$1" = ""; do
	shift
	N=`expr $N + 1`
done
echo $N
