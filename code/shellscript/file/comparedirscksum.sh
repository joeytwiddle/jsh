FILE_A=`jgettmp "$1"`
FILE_B=`jgettmp "$2"`

cksumall "$1" > "$FILE_A"
cksumall "$2" > "$FILE_B"

# diff "$FILE_A" "$FILE_B"

echo "Files that are different:"
jfcsh -bothways "$FILE_A" "$FILE_B" | sed "s+.*\.\/++"
echo
echo "Files that are the same:"
jfc common "$FILE_A" "$FILE_B" | sed "s+.*\.\/++"
