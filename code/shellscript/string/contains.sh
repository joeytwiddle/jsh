RESULT=`echo "$1" | grep "$2"`
test ! "$RESULT" = ""
