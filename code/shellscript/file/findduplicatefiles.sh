echo "Note: these may be hard links,"
echo "or possibly (to check) symlinks, so don't delete the target!"
echo

if test "$1" = "--help"; then
	echo "findduplicatefiles [ -samename ]"
	echo "  -samename option expects identical filenames but is faster."
	exit 1
fi

if "$1" = "-samename"; then

	shift

	# Faster, but assumes filenames are the same
	find . -type f | sed "s+.*/++" | keepduplicatelines |
	while read X; do
		find . -name "$X" | while read Y; do cksum "$Y"; done
	done |
	keepduplicatelines -gap 1 2 |
	sed 's/[0123456789]* [0123456789]* \(.*\)/rm "\1"/'

else

	find . -type f -printf "%s %p\n" |
	keepduplicatelines 1 |
	afterfirst " " |
	while read X; do
	  cksum "$X"
	done |
	keepduplicatelines -gap 1 2

fi

# find . -type f |
# while read X; do
  # cksum "$X"
# done |
# keepduplicatelines -gap 1 2

# CKSUMS=`find . -type f | while read X; do
    # cksum "$X"
  # done`
# 
# FINDDUPS=`echo "$CKSUMS" | keepduplicatelines 1 2`
# 
# echo "$FINDDUPS" | while read X; do
  # echo "$CKSUMS" | grep "^$X"
  # echo
# done
