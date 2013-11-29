#!/bin/sh
## Using bash so we don't have to use calc below (which requires bc)
# jsh-ext-depends: hexdump
# jsh-depends: dropcols headbytes
## If the hexdump method is too inefficient:
# echo "$RANDOM" ; exit

# RNDDEV=/dev/random
RNDDEV=/dev/urandom
if [ "$USE_RND_DEV" ] || ( which hexdump >/dev/null 2>&1 && [ -e "$RNDDEV" ] )
then

	RAND_MAX=4294967295
	[ "$1" ] && START="$1" || START=0
	[ "$2" ] && END="$2" || END=4294967295

	NUM=`
		## In this case RAND_MAX is 4294967296 (numbers range 0-(65536^2 = 2^32)-1)
		cat "$RNDDEV" | headbytes 4 | hexdump -d | head -n 1 | dropcols 1 |
		while read ORDER2 ORDER1
		# do expr "$((ORDER2*65536+ORDER1))"   ## fails under bash and sh
		# do calc "$ORDER2*65536+$ORDER1"   ## works but requires bc non-standard package
		do expr "$ORDER2" "*" 65536 "+" "$ORDER1"   ## seen working on 64-bit 13.04 and 32-bit Ubuntu 12.04
		done
	`

	calc "$NUM*($END+1-$START)/$RAND_MAX+$START"

elif [ "$RANDOM" ]
then
	echo "$RANDOM"
else
	# Not on Maxx: echo "" | awk ' BEGIN { printf( int(100001*rand()) ); printf("\n"); } '
	# Um!
	echo $$
	# date +"%s" is not very random :P
fi
