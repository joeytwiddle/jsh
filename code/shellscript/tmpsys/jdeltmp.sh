TOPTMP="$JPATH/tmp"
if test $JTMPLOCAL && test -w .; then
	TOPTMP="."
fi

for X in "$@"; do
  if startswith "$X" "$TOPTMP" || startswith "$X" "/tmp/"; then
	 rm -rf "$X"
    # mkdir -p $JPATH/trash/$TOPTMP
    # mv "$X" $JPATH/trash/$X
    # del "$X" > /dev/null
  else
    echo "jdeltmp: $X does not start with $TOPTMP" > /dev/stderr
	 exit 1
  fi
done
