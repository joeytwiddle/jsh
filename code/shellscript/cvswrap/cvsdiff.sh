#!/bin/zsh

# Searches current cvs directory and looks for directories and files
# which have not yet been added to the _local_ repository.

echo '# Alternatively, try: cvs update 2>/dev/null | grep -v "^\? "' >&2
echo '# or cvs status 2>/dev/null | grep "^File: " | grep -v "Status: Up-to-date"' >&2

# To highlight lines from cvs diff -c :
# cvs diff -r 1.27 simgen.c | sed "s/^\!/"`curseyellow`"\!/;s/$/"`cursegrey`"/"
# (need to do > and < too)

REPOS="$CVSROOT/"`cat CVS/Repository`

COUNTFILES=0
COUNTDIRS=0
MISSINGDIRS=0
MISSINGFILES=0

find . | grep -v "/CVS" |
  while read SOMETHING; do
    if test -d "$SOMETHING"; then
      DIR="$SOMETHING"
      COUNTDIRS=`expr $COUNTDIRS + 1`
      # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      if test ! -d "$REPOS/$DIR"; then
        echo 'cvs add "'$DIR'" # dir'
        MISSINGDIRS=`expr $MISSINGDIRS + 1`
      fi
    else
      FILE="$SOMETHING"
      COUNTFILES=`expr $COUNTFILES + 1`
      CVSFILE="$REPOS/$FILE,v"
      if test ! -f "$CVSFILE"; then
        MISSINGFILES=`expr $MISSINGFILES + 1`
        echo 'cvs add "'$FILE'"'
      fi
    fi
  done

# find . -type d | grep -v "/CVS" |
  # while read DIR; do
    # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      # echo 'cvs add "'$DIR'"'
    # fi
  # done
# 
# find . -type f | grep -v "/CVS/" |
  # while read FILE; do
    # COUNTFILES=`expr $COUNTFILES + 1`
    # CVSFILE="$CVSROOT/$CHKOUT/$FILE,v"
    # if test ! -f "$CVSFILE"; then
      # MISSINGFILES=`expr $MISSINGFILES + 1`
      # if test $DOADD; then
        # echo 'cvs add "'$FILE'"'
      # else
        # echo "$FILE"
      # fi
    # fi
  # done

echo "# $MISSINGFILES / $COUNTFILES files missing, $MISSINGDIRS / $COUNTDIRS directories." >&2
