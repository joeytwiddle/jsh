OTHERDIR="$1"
if test "x$OTHERDIR" = "x"; then
  echo "# Syntax: removeduplicatefiles [-doit] <other-dir>"
  exit 1
fi
DOIT=false
if test "$OTHERDIR" = "-doit"; then
  DOIT=true
  OTHERDIR="$2"
fi
# WHAT="$2"
# if test "x$WHAT" = "x"; then
#   WHAT="*";
# fi

find . -type f | while read X; do
# for X in $WHAT; do
  CMPRES=`cmp "$X" "$OTHERDIR/$X" 2>&1`
  CMPERR="$?"
  if test "x$CMPRES" = "x"; then
    if test "$CMPERR" = "0"; then
      # For the chop!
      if cmp "$X" "$OTHERDIR/$X" 2>&1; then
        if test "$DOIT" = "false"; then
          echo "rm \"$X\"" # "    # err=$CMPERR output=$CMPRES"
        else
          rm "$X"
        fi
      else
        echo "*** ERROR:  $X : failed on if cmp"
      fi
    else
      echo "*** ERROR: $X : err > 0 but output: $CMPRES"
    fi
  else
    if test "$CMPERR" = "0"; then
      echo "*** ERROR: $X : err=0 but got output: $CMPRES"
    else
      NICECMPRES=`echo "$CMPRES" | tr "\n" "\\n" | after "$X"`
      echo "# $X unique: $NICECMPRES"
    fi
  fi
done

echo "#"
echo "# Dangers:"
echo "# Are you sure the files you are comparing aren't symlinks to themselves?!"
echo "# To execute once satisfied use | sh , not \`...\`"
echo "# (or use -doit, which I implemented after neglecting to read this message!)"
