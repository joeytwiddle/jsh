if test "$1" = "--help"; then
	echo "cksumall [ <files> ... [ -exclude <files> ... ] ]"
	exit 1
fi

if test ! "x$1" = "x"; then
  cd "$1"
  shift
fi

find . -type f |
if test "$1" = "-exclude"; then
	shift 
	notindir "$@"
else
	cat
fi |
while read X
do
  cksum "$X"
done | tr " " "\t"
# | sort -k 3 ## filename
# | sort -k 1,2 ## cksum ?
