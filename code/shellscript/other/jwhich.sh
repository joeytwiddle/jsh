if [ "$1" = "" ]; then
  echo "jwhich <file> [ quietly | -keepj ]"
  echo "  will find the file in your \$PATH minus \$JPATH"
  exit 1
fi

FILE="$1";

# Remove all references to JLib from the path

if test "x$2" = "-keepj"; then
  path="$PATH"
else
  PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "$JPATH" | grep -v "^.\$"`;
fi

for dir in $PATHS; do
  if [ -f "$dir/$1" ]; then
    if [ ! "$2" = "quietly" ]; then
      echo $dir/$1
    fi
    exit 0      # Found!  :)
  fi
done

if [ ! "$2" = "quietly" ]; then
  echo "Could not find $1 in any of "`echo "$PATHS" | tr "\n" ":"`
fi
exit 1          # Not found  :(

# OLDPATH="$PATH";
# NEWPATH=`echo "$PATH" | tr ":" "\n" | grep -v "$JPATH" | tr "\n" ":"`;
# PATH="$NEWPATH.";
# echo "$PATH"
# COM=`which $1`;
# if test "$COM" = ""; then
#   echo "Could not find $1"
# else
#   echo "$COM"
# fi
# export PATH="$OLDPATH";
