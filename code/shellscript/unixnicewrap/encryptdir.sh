DIR="$1"
FILE="$DIR.tgz.encrypted"

test -f "$FILE" &&
mv "$FILE" "$FILE.bak"

touch "$FILE"
chmod 600 "$FILE"

tar cz "$DIR" |
gpg -r "Paul Clark <pclark@cs.bris.ac.uk>" -e > "$FILE"
