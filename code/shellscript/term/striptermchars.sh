## Removes all special terminal characters from stream
## Problem with strings, is it also strips adjacent newlines.
# strings
sed 's+[^m]*m++g' "$@"
