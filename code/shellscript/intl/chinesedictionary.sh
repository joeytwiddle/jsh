if test "$1" = "-h" || test "$1" = "--help"; then
	echo "chinesedictionary [-k|-c] [g|b]"
	echo "  where g means use GB dictionary,"
	echo "        b means use BIG5 dictionary,"
	echo "        -k means use kterm,"
	echo "        -c means use crxvt."
	exit 0
fi

USEDICT="g"
# default to crxvt because kterm appears to be doing kanji!
XTERMTOUSE=crxvt
ARGS="-im xcin -pt Root"
export LANG=fake

for X; do
	if test "$X" = "-k"; then
		# Delete doesn't work and highlight-paste dodgy!
		XTERMTOUSE=kterm
	elif test "$X" = "-c"; then
		XTERMTOUSE=crxvt
		ARGS="-im xcin -pt Root"
		# To prevent crxvt from hanging:
		export LANG=fake
	else
		USEDICT="$X"
	fi
done

FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-120-*-*-m-*-iso8859-1'

$XTERMTOUSE $ARGS \
	+sb -sl 5000 -vb -si -sk -bg black -fg white -font "$FONT" \
	-e jcedict "$USEDICT" "ChineseDictLookup $USEDICT ($XTERMTOUSE)" &

