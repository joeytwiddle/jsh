if test "$2" = ""; then
	echo "datediff <earlierfile> <laterfile>"
	exit 1
fi

# date -r "$1"
# date -r "$2"

DATEA=`date -r "$1" "+%s"`
DATEB=`date -r "$2" "+%s"`

DATEDIFF=`expr "$DATEB" - "$DATEA"`

SECS="$DATEDIFF"
MINS=`expr "$DATEDIFF" / 60`
SECS=`expr "$SECS" - "$MINS" '*' 60`
HOURS=`expr "$MINS" / 60`
MINS=`expr "$MINS" - "$HOURS" '*' 60`
DAYS=`expr "$HOURS" / 24`
HOURS=`expr "$HOURS" - "$DAYS" '*' 24`
MONTHS=`expr "$DAYS" / 30`
DAYS=`expr "$DAYS" - "$MONTHS" '*' 30`
YEARS=`expr "$MONTHS" / 12`
MONTHS=`expr "$MONTHS" - "$YEARS" '*' 12`

STARTED=
if test $STARTED || test "$YEARS" -gt 0; then
	printf "$YEARS years, "
	STARTED=true
fi
if test $STARTED || test "$MONTHS" -gt 0; then
	printf "$MONTHS months, "
	STARTED=true
fi
if test $STARTED || test "$DAYS" -gt 0; then
	printf "$DAYS days, "
	STARTED=true
fi
if test $STARTED || test "$HOURS" -gt 0; then
	printf "$HOURS hours, "
	STARTED=true
fi
if test $STARTED || test "$MINS" -gt 0; then
	printf "$MINS minutes, "
	STARTED=true
fi
printf "$SECS seconds."
printf "\n"
