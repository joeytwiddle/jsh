#!/usr/bin/env bash
### Bash built-in
echo "${#1}"
exit



### Alternative

#!/bin/sh

printf "%s" "$*" | wc -m
exit



### Original:

# jsh-depends: countlines
# if test ! "$1" = ""; then
echo "$@" |
# else
	# cat
# fi |
tr -d "\n" |
sed 's/./\
/g' |
countlines
