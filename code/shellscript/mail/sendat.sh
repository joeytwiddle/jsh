COM="$1"
TIME="$2"
TO="$3"
DIR="$JPATH/data/mail/tosend-$TIME"
SENDSCRIPT="$DIR/sendscript.sh"

if test "$COM" = "sched"; then

	mkdir -p "$DIR"
	FILE=`getuniquefile "$DIR/email-"`
	cat > "$FILE"
	echo "mail $TO < $FILE" >> $SENDSCRIPT
	
	# Fake a real sending by pausing
	WAITSECS=`listnums 10 100 | chooserandomline`
	echo "sleep "$WAITSECS"s" >> $SENDSCRIPT

elif test "$COM" = "dosend"; then

	# Fake a real sending by pausing
	WAITMINS=`listnums 5 40 | chooserandomline`
	echo "Will send in $WAITMINS minutes"
	sleep $WAITMINS"m"
	WAITSECS=`listnums 1 30 | chooserandomline`
	sleep $WAITSECS"s"

	. "$SENDSCRIPT"
	del "$SENDSCRIPT"
	del "$DIR/*"
	# SENTDIR="$JPATH/mail/sent"
	# mkdir -p "$SENTDIR"
	# mv "$DIR/*" "$SENTDIR"

fi
