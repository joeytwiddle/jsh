URL="$1"
cat_from_url "$URL" |
tr -d '\n' | grep -i -o "<title[^<]*" | sed 's+[^>]*>++' |
fromhtml
