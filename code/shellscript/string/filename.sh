if test "x$1" = "x"; then
  afterlast "/"
else
  FILENAME="$1"
  # lack on -n causes del to append ' '
  AFTERSLASH=`echo -n "$FILENAME" | afterlast '/'`
  if test "x$AFTERSLASH" = "x"; then # Was a directory
    echo "$FILENAME" | sed 's+/$++' | afterlast '/'
    # echo "$FILENAME" | betweenthe "/" | tail -1
    # | head -1
  else
    echo "$AFTERSLASH"
  fi
fi
