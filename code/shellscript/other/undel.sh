if test "$1" = ""; then
  ls $JPATH/trash/$PWD
else
  FILE="$JPATH/trash/$PWD/$1"
  if test ! -f "$FILE"; then
    if test ! -d "$FILE"; then
      echo "Sorry - $FILE is neither a file or directory."
      echo "Try one of these ..."
      find $JPATH/trash -name "$1"
      exit 1
    fi
  fi
  mv "$FILE" .
  echo "./$1 <- $FILE"
fi
