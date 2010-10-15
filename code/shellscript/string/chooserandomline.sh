#!/bin/sh
# jsh-depends: randomorder
## For other implementations, see: http://wooledge.org:8000/BashFAQ/026

## Simple method.  Inefficient on large input, since it needs to parse all those lines for sorting!
## OLD: randomorder "$@" | ( head -n 1; cat > /dev/null)
cat "$@" | randomorder | head -n 1
exit



if [ "$1" ]
then
	## If file is known, we can use efficient method:
	# NUMLINES=`wc -l "$1"`
	NUMLINES=`cat "$1" | wc -l`
	RNDLINE=`seq 1 "$NUMLINES" | randomorder | head -n 1`
	getline "$RNDLINE" "$@"
	exit
fi



## I've decided to use the seek-line-in-file method above
## This is more efficient on large input files.
cat > /tmp/randomorder.$$
chooserandomline /tmp/randomorder.$$
rm -f /tmp/randomorder.$$

# awk '
  # BEGIN {
    # FS="\n";
    # srand();
  # }
  # {
    # printf(int(100001*rand())": ");
    # print $1;
  # }
# ' "$@" | sort -k 1 | head -n 1 | afterlastall ": "
