for I in "$@"
do
	nice --20 mpg123 --cdr - "$I" |
	nice --20 cdrecord -dev=0,0,0 -audio -pad -nofix -
done
nice --20 cdrecord -fix
