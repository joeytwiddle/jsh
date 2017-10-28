#!/usr/bin/env sh

pgrep -l "$@" |

while read pid pname
do
  readlink /proc/"${pid}"/fd/* |
  grep -v "^/dev/" |
  grep -v "^socket:" |
  grep -v "^pipe:" |
  grep -v "^anon_inode:" |
  sed "s/^/${pid} ${pname}	/"
done |
sort -n -k 1
