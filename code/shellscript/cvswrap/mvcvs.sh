if test ! "$3" = ""; then
  echo "mvcvs: takes only two arguments (one source, one dest)"
  exit 1
fi

echo "% cp \"$1\" \"$2\""
cp "$1" "$2"
echo "% del \"$1\""
del "$1"
echo "% cvs add \"$2\""
cvs add "$2"

echo "Note: if your dest was a directory, then the dest file may not be added to the repository, even though the source is removed!"
