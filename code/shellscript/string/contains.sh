## Note now different syntax to endswith.

if test "$1" = "" || test "$1" = "--help"
then
	echo "contains <string> <search_string>"
	echo "stream | contains <search_string>"
	exit 1
fi

if test "$2" = ""
then             grep "$1" > /dev/null
else echo "$1" | grep "$2" > /dev/null
fi

# RESULT=`echo "$1" | grep "$2"`
# test ! "$RESULT" = ""
