FILEX=`jgettmp "First com:  $1"`
FILEY=`jgettmp "Second com: $2"`
# $1 > "$FILEX"
# $2 > "$FILEY"
echo "$1" | sh > "$FILEX"
echo "$2" | sh > "$FILEY"
jfc "$FILEX" "$FILEY"
jdeltmp "$FILEX" "$FILEY"
