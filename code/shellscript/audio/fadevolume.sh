if test $1; then
	GAP=$1
else
	GAP=60
fi

STARTVOL=`aumix -q | grep "vol" | after "vol " | before ","`

for X in `seq $STARTVOL 0`; do
	echo $X
	aumix -v $X
	sleep $GAP
done
