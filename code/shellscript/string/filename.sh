# jsh-ext-depends: sed basename
# jsh-depends: afterlast
basename "$1"
exit

## Deprecated until needed (and fixed $1="" ... :-/ )
## Oops maybe I could just use basename "$1" !
## Indeed, filename "" is locking!
if test "x$1" = "x"; then
  afterlast "/"
else
  FILENAME="$1"
  # lack on -n causes del to append ' '
  AFTERSLASH=`echo -n "$FILENAME" | afterlast '/'`
  if test "x$AFTERSLASH" = "x"; then # Was a directory
    echo "$FILENAME" | sed 's+/$++' | afterlast '/'
    # echo "$FILENAME" | betweenthe "/" | tail -n 1
    # | head -n 1
  else
    echo "$AFTERSLASH"
  fi
fi
