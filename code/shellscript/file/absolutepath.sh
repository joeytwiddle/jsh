if test "$*" = ""; then
  echo "absolutepath <file>"
  echo "  or"
  echo "absolutepath <parentdir> <file>"
  exit 1
fi

if test "$2" = ""; then
  PARENT="$PWD"
  FILE="$1"
else
  PARENT="$1"
  FILE="$2"
fi

if isabsolutepath "$FILE"; then
  echo "$FILE"
else
  echo "$PARENT/$FILE"
fi
