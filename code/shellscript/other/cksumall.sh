if test ! "x$1" = "x"; then
  cd "$1"
fi
find . -type f | while read X; do
  cksum "$X"
done | tr " " "\t" | sort -k 3
