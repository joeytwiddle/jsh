for I in "$@"
do
	mpg123 --cdr - "$I" |
	cdrecord -dev=0,0,0 -audio -pad -nofix -
done
cdrecord -fix
