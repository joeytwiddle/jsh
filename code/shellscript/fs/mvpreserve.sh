#!/bin/sh
## Uses cp -a to preserve the files meta-info (e.g. last-modified date)

## Damn it doesn't work; better use touch instead to copy that info

## No wait I think the problem is when I try to write to my FAT fs but it has been mounted as root.  :P

cp -a "$@" &&
while [ "$2" ]
do
	del "$1"
	shift
done
