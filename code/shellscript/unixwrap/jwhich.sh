#!/usr/local/bin/zsh
if [ "$1" = "" ]; then
  echo "jwhich [ inj ] <file> [ quietly ]"
  echo "  will find the file in your \$PATH minus \$JPATH (unless inj specified)"
  exit 1
fi

if test "$1" = "inj"; then
  FILE="$2"
  QUIETLY="$3"
  PATHS=`echo "$PATH" | tr ":" "\n"`
else
  FILE="$1"
  QUIETLY="$2"
  # Remove all references to JLib from the path
  PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "$JPATH" | grep -v "^.\$"`;
  # PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "^$JPATH/tools" | grep -v "^.\$"`;
fi

# for dir in $PATHS; do
echo $PATHS | while read dir; do
  if [ -f "$dir/$FILE" ]; then
    if [ ! "$QUIETLY" = "quietly" ]; then
      echo $dir/$FILE
    fi
    exit 0      # Found!  :)
  # else
    # echo "$dir/$FILE does not exist"
  fi
done

if [ ! "$QUIETLY" = "quietly" ]; then
  echo "Could not find $FILE in any of $PATHS"
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
