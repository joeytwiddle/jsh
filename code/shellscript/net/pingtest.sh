REPORTFILE=`jgettmp "ping$*"`

printf "" > $REPORTFILE

(
	ping -c 5 "$@" > /dev/null
	echo "$?" > $REPORTFILE
) &

sleep 60
REPORT=`cat $REPORTFILE`

jdeltmp $REPORTFILE

if test "$REPORT" = "0"
then
	echo "ping succeeded"
	exit 0
else
	echo "ping failed"
	exit 1
fi
