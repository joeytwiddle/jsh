## tocol 9 will stream the first 8 columns, stripping all after
COLUMN="$1" ; shift
COLUMN=$((COLUMN-1))
sed 's+  *+ +g' |   ## CONSIDER: Is this any different from tr -s ' '?
cut -d " " -f "-$COLUMN"
