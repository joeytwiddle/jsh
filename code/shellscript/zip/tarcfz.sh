# For unix tar lacking the z option
ZIPFILE="$1"
shift
tar cf - "$@" | gzip > "$ZIPFILE"
