PADLEFT=">"
PADBRACE=" "
PADRIGHT="<"

if test "$1" = "-pad"; then
	shift
	PADLEFT="$1"
	PADBRACE="$2"
	PADRIGHT="$3"
	shift; shift; shift
fi

if test "$COLUMNS" = ""; then COLUMNS=80; fi
LEN=`strlen "$@"`
REMAINING=`expr "$COLUMNS" - "$LEN"`
LEFT=`expr "$REMAINING" / 2 - 2`
for X in `seq 1 $LEFT`
do
	printf "%s" "$PADLEFT"
done
printf "%s" "$PADBRACE$@$PADBRACE"
for X in `seq 1 $LEFT`
do
	printf "%s" "$PADRIGHT"
done
printf "\n"
