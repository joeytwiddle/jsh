TARGET="$*"

## Did the user give a number, or a name to look up?

TESTNUM=`echo "$TARGET" | extractregex "[[:digit:] ]+"`
if [ "$TESTNUM" = "$TARGET" ]
then

	CHOICE="$TARGET"

else

	phonelookup "$TARGET" | highlight "$*"

	CHOICE=`
		phonelookup "$TARGET" |
		extractregex "[0-9]+( [0-9]+|)" |
		head -n 1
	`

	if [ ! "$CHOICE" ]
	then exit 1
	fi

fi

CHOICE=`echo "$CHOICE" | tr -d ' '`

echo "Do you want me to call $CHOICE?"
read ANSWER

if [ ! "$ANSWER" = y ]
then exit 0
fi

CHATSCRIPT=/etc/chatscripts/justdial
cat $CHATSCRIPT |
sed "s+^OK-AT-OK ATDT.*+OK-AT-OK ATDT$CHOICE+" |
dog $CHATSCRIPT

sudo `which ppp-off`

# while findjob pppd; do : ; done

# sleep 10 # =kill in ppp-off makes it immediate

echo "Calling..."

sudo pppd call justdial

