if test "$2" = "" -o ! "$3" = ""; then
  echo "mvcvs: takes only two arguments (one source, one dest)"
  exit 1
fi

# FILE="$1"
# DESTDIR="$2"
# FNAME=`filename "$FILE"`
# if test -d "$DESTDIR"; then
  # TOADD="$DESTDIR/$FNAME"
# else
  # TOADD="$DESTDIR"
# fi
# 
# echo "cp \"$FILE\" \"$DESTDIR\""
# # cp "$FILE" "$DESTDIR"
# echo "del \"$FILE\""
# # del "$FILE"
# echo "cvs add \"$TOADD\""
# # cvs add "$TOADD"
# 
# echo "Warning: if your dest is a file, as opposed to a directory, it may not be added correctly."

LOCALFILE="$1"
LOCALDESTDIR="$2"

FILEPATH=`filepath "$LOCALFILE"`
FILENAME=`filename "$LOCALFILE"`
REPOSFILEDIR=`cat "$FILEPATH/CVS/Repository"`
REPOSDESTDIR=`cat "$LOCALDESTDIR/CVS/Repository"`

# Last line doesn't work if LOCALDESTDIR not in cvsroot repository!

echo "# Moving $FILEPATH / $FILENAME in $REPOSLOCAL"

CVSFILE="$CVSROOT/$REPOSFILEDIR/$FILENAME,v"
CVSDESTDIR="$CVSROOT/$REPOSDESTDIR"

if test ! -d "$FILEPATH"; then
  echo "Probleming resolving local directory.  Got \"$FILEPATH\""
  exit 1
fi
if test ! -d "$CVSDESTDIR"; then
  echo "CVS destination \"$CVSROOT\" is not a directory."
  exit 1
fi
if test ! -f "$LOCALFILE"; then
  echo "\"$LOCALFILE\" is not a file!"
  exit 1
fi
if test ! -f "$CVSFILE"; then
  echo "cvs file \"$CVSFILE\" does not exist!"
  exit 1
fi

echo "mv \"$LOCALFILE\" \"$LOCALDESTDIR/\""
if test ! -d "$CVSDESTDIR"; then
  echo "mkdir -p \"$CVSDESTDIR\""
fi
echo "mv \"$CVSFILE\" \"$CVSDESTDIR/\""
