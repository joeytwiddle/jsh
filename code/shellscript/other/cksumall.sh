if test ! "x$*" = "x"; then
  cd $*
fi
find . -type f | while read X; do
  cksum "$X"
done | sort -k 3
