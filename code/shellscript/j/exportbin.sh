for x in "$@"; do
	if isabsolutepath $x; then
		SRCDIR=`dirname $x`
	else
		SRCDIR=`dirname $PWD/$x`
	fi
	# echo "$SRCDIR"
  JCODEDIR=`echo "$SRCDIR" | sed "s:^"$JPATH"/code/::"`
  DESTDIR="$JPATH/bin/$JCODEDIR"
  echo "$SRCDIR/"`filename $x`" -> $DESTDIR"
  mkdir -p "$DESTDIR"
  mv $x "$DESTDIR"
  if test -d "CVS"; then
	  cvs remove $x
  fi
done
