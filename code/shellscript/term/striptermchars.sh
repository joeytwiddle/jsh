## Removes all special terminal characters from stream
sed 's+[^m]*m++g' "$@"
