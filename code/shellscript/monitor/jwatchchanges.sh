DELAY=3s
if [ "$1" = -n ]
then DELAY=$2; shift; shift
fi

COM="$@"

TMPFILEA=`jgettmp jwatchchanges "$COM"`
TMPFILEB=`jgettmp jwatchchanges "$COM"`
TMPFILEC=`jgettmp jwatchchanges diff_"$COM"`

eval "$COM" > $TMPFILEA

while true
do

	eval "$COM" > $TMPFILEB

	cp $TMPFILEA $TMPFILEC

	diff -U0 $TMPFILEA $TMPFILEB |
	sed 's|^+ \(.*\)|+ '`curseyellow`'\1'`cursenorm`'|' |
	patch $TMPFILEC

	clear
	echo "Every $DELAY: $COM     `date`"
	echo
	cat $TMPFILEC

	sleep $DELAY

	cp $TMPFILEB $TMPFILEA

done

## TODO: jdeltmp $TMPFILEA $TMPFILEB $TMPFILEC after user breaks out!
