# jsh-depends: startswith
TOPTMP="$JPATH/tmp"

# if test $JTMPLOCAL && test -w .; then
	# TOPTMP="."
# fi

if test ! -w "$TOPTMP"
then
	TOPTMP="/tmp/jsh-tempdir-for-$USER"
	mkdir -p $TOPTMP
	chmod go-rwx $TOPTMP
fi

for TMPFILE
do
  if startswith "$TMPFILE" "$TOPTMP" || startswith "$TMPFILE" "/tmp/" ||
     ( test "$TMPDIR" && startswith "$TMPFILE" "$TMPDIR" )
  then
    rm -rf "$TMPFILE"
    # mkdir -p $JPATH/trash/$TOPTMP
    # mv "$TMPFILE" $JPATH/trash/$TMPFILE
    # del "$TMPFILE" > /dev/null
  else
    jshwarn "jdeltmp: $TMPFILE does not start with $TOPTMP"
    exit 1
  fi
done
