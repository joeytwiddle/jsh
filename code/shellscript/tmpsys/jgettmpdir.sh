TMP=`jgettmp "$@"`
jdeltmp "$TMP"
mkdir -p "$TMP"
chmod go-rwx "$TMP"
echo "$TMP"
