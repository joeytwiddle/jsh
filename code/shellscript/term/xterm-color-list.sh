#!/bin/sh
set -e

for i in {0..255}
do
	if [ $i = 8 ] || ( [ $i -gt 15 ] && [ $(( (i - 16) % 6 )) = 0 ] )
	then echo
	fi
	printf '\e[48;5;%d;30m %3d \e[0m' $i $i
done
echo
