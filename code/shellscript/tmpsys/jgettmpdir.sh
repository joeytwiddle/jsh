# Makes bash exit if jgettmp fails.
set -e
TMP=`jgettmp "$@"`
jdeltmp "$TMP"
mkdir -p "$TMP"
chmod go-rwx "$TMP"
echo "$TMP"
