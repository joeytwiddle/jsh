#!/bin/sh

echo "$PATH" | tr ':' '\n' |
while read dir
do
	[ -r "$dir" ] && find "$dir"/ -maxdepth 1 -type f -or -type l |
	while read executable
	do [ -x "$executable" ] && echo "$executable"
	done
done |
afterlast /
