echo "Note: these may be hard links,"
echo "or possibly (to check) symlinks, so don't delete the target!"
echo

if test "$1" = "" || test "$1" = "--help" || test "$1" = "-h"; then
	echo "findduplicatefiles [ -size ] [ -samename ] [ <files/directories>... ]"
	echo "  -size     : use file size instead of checksum (faster)."
	echo "  -samename : expect identical filenames (faster)."
	exit 1
fi

HASH="cksum"
if test "$1" = "-size"; then
	shift
	HASH="filesize -likecksum"
	echo 'Possible usage: findduplicatefiles -size | while read X Y Z; do if test "$Z"; then cksum "$Z"; else echo; fi done' >> /dev/stderr
fi

SAMENAME=
if test "$1" = "-samename"; then
	SAMENAME=true
	shift
fi

WHERE="$*"
test "$WHERE" || WHERE="."

if test $SAMENAME; then

	# Faster, but assumes filenames are the same
	find $WHERE -type f | sed "s+.*/++" | keepduplicatelines |
	while read X; do
		find . -name "$X" | while read Y; do $HASH "$Y"; done
	done |
	keepduplicatelines -gap 1 2 |
	sed 's/[0123456789]* [0123456789]* \(.*\)/rm "\1"/'

else

	find $WHERE -type f -printf "%s %p\n" |
	keepduplicatelines 1 |
	afterfirst " " |
	while read X; do
	  $HASH "$X"
	done |
	keepduplicatelines -gap 1 2

fi
