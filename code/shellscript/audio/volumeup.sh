HOWMUCH="$1"
if test ! $HOWMUCH; then
	HOWMUCH=6
fi
VOL=`aumix -q | grep "vol" | after "vol " | before ","`
VOL=`expr $VOL + $HOWMUCH`
aumix -v $VOL
