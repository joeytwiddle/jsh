# This addition not documented,
# and not really needed since we have imageinfo
MULTIPLE=
if test "$1" = "-:"; then
	MULTIPLE=true
	shift
fi
if test ! "$2" = ""; then
	MULTIPLE=true
fi

for X in "$@"; do
  if test $MULTIPLE; then
    printf "$X:	"
  fi
  imageinfo "$X" | head -n 1 | after "$X " | beforefirst ' ' | beforefirst "+"
  # | tail -n 1 | beforefirst ' '
  # | takecols 2
done
