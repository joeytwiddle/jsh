#!/usr/bin/env sh

pgrep -l "$@" |

while read pid pname
do
  readlink /proc/"${pid}"/fd/* |
  egrep -v "^/(dev|proc)/" |
  egrep -v "^(socket|pipe|anon_inode):" |
  sed "s/^/${pid} ${pname}	/"
done |
sort -n -k 1
