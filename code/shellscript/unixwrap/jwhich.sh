if [ "$1" = "" ]; then
  echo "jwhich <files> [ quietly ]"
  echo "  will return the first file it finds in your \$PATH minus \$JPATH"
  echo "  or an error if none of them are in any of your paths."
  exit 1
fi

# Remove all references to JLib from the path

PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "$JPATH" | grep -v "^.\$"`;

for FILE in $@; do
  for dir in $PATHS; do
    if [ -f "$dir/$FILE" ]; then
      if [ ! "$2" = "quietly" ]; then
        echo $dir/$FILE
      fi
      exit 0      # Found!  :)
    fi
  done
done

if [ ! "$2" = "quietly" ]; then
  echo "Could not find any of $@ in any of"
  echo "$PATHS"
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