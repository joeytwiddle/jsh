## BUGS: TODO: SERIOUS problem: ignores my speed=1 request and writes speeded-up audio !

## TODO: don't allow overburning (could try using mp3duration)
## TODO: what about oggs?!

if [ "$1" = -announce ]
then
	for TRACK
	do
		FILENAME=`basename "$TRACK"`
		echo "$FILENAME"
		mp3info "$FILENAME"
		## ...
	done
	exit
fi

if test "$1" = -fix
then FIX=true; shift
else
	FIX=
	echo "`cursered``cursebold`Don't forget to -fix on (or after) the last write!`cursenorm`"
fi

CDRECORD_OPTS="minbuf=90 fs=31M speed=8"
## Recommended fix for buffer underruns
CDRECORD_OPTS="$CDRECORD_OPTS driveropts=burnfree"
## But I doubt it fixes octupal-speed audio!

for I in "$@"
do
	nice --20 mpg123 --cdr - "$I" |
	nice --20 cdrecord $CDRECORD_OPTS -dev=0,0,0 -audio -pad -nofix - || exit 1
done

if [ "$FIX" ]
then nice --20 cdrecord $CDRECORD_OPTS -dev=0,0,0 -fix
else echo "`cursered``cursebold`Don't forget to -fix on (or after) the last write!`cursenorm`"
fi
