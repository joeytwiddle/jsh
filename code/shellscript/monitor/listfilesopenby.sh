#!/usr/bin/env sh

if [ -z "$1" ] || [ "$1" = --help ]
then cat << !

listfilesopenby [<pgrep_options>...] <process_name>

!
exit 1
fi

pgrep -l "$@" |

while read pid pname
do
  readlink /proc/"${pid}"/fd/* |
  grep -E -v "^/(dev|proc)/" |
  grep -E -v "^(socket|pipe|anon_inode):" |
  sed "s/^/${pid} ${pname}	/"
done |
sort -n -k 1
