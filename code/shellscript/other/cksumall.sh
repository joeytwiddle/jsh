if test "$1" = "--help"; then
	echo "cksumall [ <directories> [ <find_options> ] ]"
	exit 1
fi

if test ! "$CKSUMCOM"
then CKSUMCOM="cksum"
fi

# 'ls' -R "$@" | ls-Rtofilelist |
find "$@" -type f |
while read X
do
  # ls -l "$X"
  "$CKSUMCOM" "$X"
done
# | sed 's#\([^ ]*\)[ ]*\([^ ]*\)[ ]*#\1	\2	#'
# tr " " "\t"
# sort -k 3 ## filename
# sort -k 1,2 ## cksum
