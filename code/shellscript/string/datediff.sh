if test "$2" = ""; then
	echo "datediff <earlierdate> <laterdate>"
	echo "           expressed in seconds since 1970"
	echo "datediff -files <earlierfile> <laterfile>"
	echo "TODO: option for format yyyymmddhhmmss"
	exit 1
fi

if test "$1" = "-files"
then
	shift
	DATEA=`date -r "$1" "+%s"`
	DATEB=`date -r "$2" "+%s"`
else
	DATEA="$1"
	DATEB="$2"
fi

DATEDIFF=`expr "$DATEB" - "$DATEA"`

# year 12 month 30 day 24 hour 60 minute 60 second
# second 60 minute 60 hour 24 day 30 month 12 year

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
	printf "$YEARS year"
	if test "$YEARS" -gt 1; then
		printf "s"
	fi
	printf ", "
	STARTED=true
fi
if test $STARTED || test "$MONTHS" -gt 0; then
	printf "$MONTHS month"
	if test "$MONTHS" -gt 1; then
		printf "s"
	fi
	printf ", "
	STARTED=true
fi
if test $STARTED || test "$DAYS" -gt 0; then
	printf "$DAYS day"
	if test "$DAYS" -gt 1; then
		printf "s"
	fi
	printf ", "
	STARTED=true
fi
if test $STARTED || test "$HOURS" -gt 0; then
	printf "$HOURS hour"
	if test "$HOURS" -gt 1; then
		printf "s"
	fi
	printf ", "
	STARTED=true
fi
if test $STARTED || test "$MINS" -gt 0; then
	printf "$MINS minute"
	if test "$MINS" -gt 1; then
		printf "s"
	fi
	printf " and "
	STARTED=true
fi
printf "$SECS second"
if test "$SECS" -gt 1; then
	printf "s"
fi
echo
