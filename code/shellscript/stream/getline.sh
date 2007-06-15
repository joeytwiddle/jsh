## See also: takeline
LINENUMBER="$1"
shift
sed -n "$LINENUMBER"p "$@"
