if test "$1" = -fix
then FIX=true; shift
else FIX=
fi

for I in "$@"
do
	nice --20 mpg123 --cdr - "$I" |
	nice --20 cdrecord -dev=0,0,0 -audio -pad -nofix -
done

test "$FIX" && nice --20 cdrecord -dev=0,0,0 -fix
