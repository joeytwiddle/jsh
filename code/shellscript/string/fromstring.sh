ECHOBEFORE=
ECHOAFTER=true
if test "$1" = "-tostring"; then
	ECHOBEFORE=true
	ECHOAFTER=
	shift
fi

STRING="$1"

while read LINE && test ! "$LINE" = "$STRING"; do
	echo "$LINE"
done |
if test $ECHOBEFORE; then cat; else cat > /dev/null; fi

while read LINE; do
	echo "$LINE"
done |
if test $ECHOAFTER; then cat; else cat > /dev/null; fi
