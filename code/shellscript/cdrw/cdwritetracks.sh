## TODO: don't allow overburning

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

CDRECORD_OPTS="minbuf=90"

for I in "$@"
do
	nice --20 mpg123 --cdr - "$I" |
	nice --20 cdrecord $CDRECORD_OPTS -dev=0,0,0 -audio -pad -nofix -
done

test "$FIX" && nice --20 cdrecord $CDRECORD_OPTS -dev=0,0,0 -fix
