TMP=`jgettmp "$@"`
jdeltmp "$TMP"
mkdir -p "$TMP"
echo "$TMP"
