FILEA="$1"
FILEB="$2"

jfc diff "$FILEA" "$FILEB"

vim "$FILEA.diff" "$FILEB.diff" -c '/@@>>'
