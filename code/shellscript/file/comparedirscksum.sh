FILE_A=$JPATH/tmp/first.cksum
FILE_B=$JPATH/tmp/second.cksum

cksumall "$1" > "$FILE_A"
cksumall "$2" > "$FILE_B"

# diff "$FILE_A" "$FILE_B"

echo "Files that are different:"
jfc "$FILE_A" "$FILE_B" | sed "s+.*\.\/++"
echo
# echo "Files that are the same:"
# jfc common "$FILE_A" "$FILE_B" | sed "s+.*\.\/++"
