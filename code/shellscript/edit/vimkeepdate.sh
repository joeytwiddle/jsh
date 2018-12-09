file="$1"
[ -f "$file" ] || ( echo "Not a file: $f" ; exit 1 )
oldDate="`LC_TIME=C date -r "$file"`"
vim "$@"
date -d "$oldDate" "$file"
