#!/bin/sh

# #!/usr/local/bin/zsh

# echo "jwhich: $@"

if [ "$1" = "" ]; then
  echo "jwhich [ inj ] <file> [ quietly ]"
  echo "  will find the file in your \$PATH minus \$JPATH (unless inj specified)"
  exit 1
fi

if test "$1" = "inj"; then
  PATHS=`echo "$PATH" | tr ":" "\n"`
  shift
else
  # Remove all references to JLib from the path
  PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "$JPATH" | grep -v "^.\$"`;
  # PATHS=`echo "$PATH" | tr ":" "\n" | grep -v "^$JPATH/tools" | grep -v "^.\$"`;
fi
FILE="$1"
QUIETLY="$2"

# echo "JPATH = $JPATH" > ~/tmp.txt
# echo "PATHS = $PATHS" >> ~/tmp.txt
# echo "file = $FILE" >> ~/tmp.txt

# for dir in $PATHS; do
# Note the quotes around $PATHS here are important, otherwise unix converts into one line again!
echo "$PATHS" | while read dir; do
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
  echo "Could not find $FILE in any of"
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
