HOWMUCH="$1"
if test ! $HOWMUCH; then
	HOWMUCH=10
fi
VOL=`aumix -q | grep "vol" | after "vol " | before ","`
VOL=`expr $VOL - $HOWMUCH`
aumix -v $VOL
