## Generically handles before / after.
## But doesn't handle both at the same time!
## Could also generically use grep or [ = ]
## But current implementation wastes much processing!  (Not true!)
## The search string is not printed (it's excluded).

ECHOBEFORE=
ECHOAFTER=true
if [ "$1" = -tostring]
then
	ECHOBEFORE=true
	ECHOAFTER=
	shift
fi

STRING="$1"

while read LINE && [ ! "$LINE" = "$STRING" ]
do echo "$LINE"
done |
if [ $ECHOBEFORE ]
then cat
else cat > /dev/null
fi

if [ $ECHOAFTER ]
then cat
else cat > /dev/null
fi
