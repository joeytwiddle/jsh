
filetodiff () {
	echo "$1" > /tmp/1
	echo "$2" > /tmp/2
	CHARS=`
		cmp /tmp/1 /tmp/2 |
		sed "s/.*char \([^,]*\), line 1/\1/"
	`
	# cmp /tmp/1 /tmp/2
	echo "%%% >$CHARS<" > /dev/stderr
	if test "$CHARS" = ""; then
		printf "0"
	else
		CHARS=`expr "$CHARS" - 2`
		cat /tmp/1 | sed "s/\(.\)/\1\\
/g" | head -$CHARS | tr -d "\n"
	fi
}

STACK=""
CURRENT=""
LASTLINE="-------- START --------"
N=0

while read LINE; do
	echo
	echo "!!! $N $CURRENT"
	echo ">>> $LINE"
	if ! startswith "$LINE" "$CURRENT"; then
		echo "*** not inside current: >$LINE<"
		N=`expr "$N" - 1`
		CURRENT=`echo "$STACK" | tail -1`
		STACK=`echo "SSTACK" | chop 1`
		echo "### end"
		echo "$LASTLINE }"
	else
		echo "*** inside current: >$LINE<"
		echo "((( $LASTLINE"
		DIFF=`
			filetodiff "$LASTLINE" "$LINE" |
			sed "s^$CURRENT"
		`
		echo "@@@ $DIFF"
		if test "$DIFF" = ""; then
			echo "### normal"
			echo "$LASTLINE"
		else
			N=`expr "$N" + 1`
			STACK="$STACK
$CURRENT"
			CURRENT="$CURRENT$DIFF"
			echo "### start $DIFF"
			echo "$LASTLINE {"
		fi
	fi
	LASTLINE="$LINE"
done

echo "$CURRENT"
echo "} # for good measure"

