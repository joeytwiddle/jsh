#!/bin/sh
# jsh-depends: randomorder

if [ "$1" ]
then
	# NUMLINES=`wc -l "$1"`
	NUMLINES=`cat "$1" | wc -l`
	RNDLINE=`seq 1 "$NUMLINES" | randomorder | head -n 1`
	getline "$RNDLINE" "$@"
	exit
fi

# randomorder "$@" | ( head -n 1; cat > /dev/null)

## I've decided to use the seek-line-in-file method above
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
