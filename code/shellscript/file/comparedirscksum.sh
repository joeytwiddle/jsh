DIR_A="$1"
DIR_B="$2"
shift
shift

FILE_A=`jgettmp "$DIR_A"`
FILE_B=`jgettmp "$DIR_B"`

cksumall "$DIR_A" "$@" > "$FILE_A"
cksumall "$DIR_B" "$@" > "$FILE_B"

# diff "$FILE_A" "$FILE_B"

echo "Files that are different:"
jfcsh -bothways "$FILE_A" "$FILE_B" | sed 's+.*\./++'
echo
echo "Files that are the same:"
jfcsh -common "$FILE_A" "$FILE_B" | sed 's+.*\./++'
