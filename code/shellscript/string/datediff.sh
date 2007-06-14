if [ "$2" = "" ]
then
        echo "datediff [-secs] <earlierdate> <laterdate>"
        echo "           provide dates in seconds since 1970"
        echo "datediff [-secs] -eng <earlierdate> <laterdate>"
        echo "           provide dates in English"
        echo "datediff [-secs] -files <earlierfile> <laterfile>"
        echo "           get dates from files."
        echo "datediff [-secs] -file <file>"
        echo "           get age of file, relative to now."
        echo "datediff [-english] <seconds>"
        echo "  Option -secs outputs difference in seconds rather than default English."
        echo "  TODO: option for format yyyymmddhhmmss"
        exit 1
fi

INSECS=
if test "$1" = "-secs"
then INSECS=true; shift
fi

if [ "$1" = -english ]
then
        DATEDIFF="$2"
        shift; shift
else

        if [ "$1" = -since ]
        then
                DATE="$2"
                shift; shift
                DATEA=`date +"%s" -d "$DATE"`
                DATEB=`date +"%s" -d now`
        elif [ "$1" = "-files" ]
        then
                shift
                DATEA=`date -r "$1" "+%s"`
                DATEB=`date -r "$2" "+%s"`
        elif [ "$1" = -file ]
        then
                shift
                DATEA=`date -r "$1" "+%s"`
                DATEB=`date "+%s"`
        elif [ "$1" = -eng ]
        then
                shift
                DATEA=`date +"%s" -d "$1"`
                DATEB=`date +"%s" -d "$2"`
        else
                DATEA="$1"
                DATEB="$2"
        fi

        DATEDIFF=`expr "$DATEB" - "$DATEA"`

fi

if test "$INSECS"
then
        echo "$DATEDIFF"
        exit 0
fi

# year 12 month 30 day 24 hour 60 minute 60 second
# second 60 minute 60 hour 24 day 30 month 12 year

## BUG TODO: doesn't deal with -ve values
##           easiest solution would be to make it +ve, do following, then restore - sign on front :)

if [ "$DATEDIFF" -lt 0 ]
then
        DATEDIFF=`expr 0 - "$DATEDIFF"` ## make it positive
        echo -n "- " ## but begin output with a minus
fi
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
        echo -n "$YEARS year"
        if test ! "$YEARS" = 1; then
                echo -n "s"
        fi
        echo -n ", "
        STARTED=true
fi
if test $STARTED || test "$MONTHS" -gt 0; then
        echo -n "$MONTHS month"
        if test ! "$MONTHS" = 1; then
                echo -n "s"
        fi
        echo -n ", "
        STARTED=true
fi
if test $STARTED || test "$DAYS" -gt 0; then
        echo -n "$DAYS day"
        if test ! "$DAYS" = 1; then
                echo -n "s"
        fi
        echo -n ", "
        STARTED=true
fi
if test $STARTED || test "$HOURS" -gt 0; then
        echo -n "$HOURS hour"
        if test ! "$HOURS" = 1; then
                echo -n "s"
        fi
        echo -n ", "
        STARTED=true
fi
if test $STARTED || test "$MINS" -gt 0; then
        echo -n "$MINS minute"
        if test ! "$MINS" = 1; then
                echo -n "s"
        fi
        echo -n " and "
        STARTED=true
fi
echo -n "$SECS second"
if test ! "$SECS" = 1; then
        echo -n "s"
fi
echo
