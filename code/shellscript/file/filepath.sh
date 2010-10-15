#!/bin/sh
# local path to file/dir

FILE="$@"

# Remove trailing '/' if a directory
FILE=`echo "$FILE" | sed 's+/$++'`

# Remove last '/' and everything after it
STRIPPEDPATH=`echo "$FILE" | beforelast "/"`

# If no slashes we get the same back
if test "x$STRIPPEDPATH" = "x$FILE"; then
  echo "."
else
  echo "$STRIPPEDPATH"
fi
