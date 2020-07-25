#!/bin/sh
set -e

file="$1"

echo "$PATH" | tr ':' '\n' |

while read dir
do [ -x "${dir}/${file}" ] && echo "${dir}/${file}"
done
