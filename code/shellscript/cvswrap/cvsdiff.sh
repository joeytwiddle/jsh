#!/bin/zsh

# Searches current cvs directory and looks for directories and files which have not yet been added to the local repository.

REPOS="$CVSROOT/"`cat CVS/Repository`

COUNT=0
COUNTDIRS=0
MISSING=0

find . | grep -v "/CVS" |
  while read SOMETHING; do
    if test -d "$SOMETHING"; then
      DIR="$SOMETHING"
      # if test ! -d "$CVSROOT/$CHKOUT/$DIR/CVS/"; then
      if test ! -d "$REPOS/$DIR"; then
        echo 'cvs add "'$DIR'"'
        COUNTDIRS=`expr $COUNTDIRS + 1`
      fi
    else
      FILE="$SOMETHING"
      COUNT=`expr $COUNT + 1`
      CVSFILE="$REPOS/$FILE,v"
      if test ! -f "$CVSFILE"; then
        MISSING=`expr $MISSING + 1`
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
    # COUNT=`expr $COUNT + 1`
    # CVSFILE="$CVSROOT/$CHKOUT/$FILE,v"
    # if test ! -f "$CVSFILE"; then
      # MISSING=`expr $MISSING + 1`
      # if test $DOADD; then
        # echo 'cvs add "'$FILE'"'
      # else
        # echo "$FILE"
      # fi
    # fi
  # done

echo "$MISSING / $COUNT files missing." >&2
echo "  ( $COUNTDIRS directories. )" >&2
