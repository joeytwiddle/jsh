#!/bin/sh
## Give or take a few characters ... !
## Counts the number of characters on each line
## If you provide a character, counts the number of occurrences of that character

awk ' BEGIN { FS="'"$1"'" } { print NF " " $0 } '
