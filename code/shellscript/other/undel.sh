FILE="$JPATH/trash/$PWD/$1"
if test ! -f "$FILE"; then
  echo "Sorry - $FILE does not exist."
  echo "Try one of these ..."
  find $JPATH/trash -name "$1"
  exit 1
fi
mv "$FILE" .
echo "./$1 <- $FILE"
