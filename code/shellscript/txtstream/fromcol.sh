COLUMN="$1" ; shift
sed 's+  *+ +g' |
cut -d " " -f "$COLUMN"-
