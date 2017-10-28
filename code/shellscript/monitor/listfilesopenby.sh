#!/usr/bin/env sh

pids="$(pgrep "$@")"

if [ -z "${pids}" ]
then
  echo "No processes found matching: $*"
  exit 1
fi

for pid in $pids
do
  readlink /proc/"${pid}"/fd/* |
  grep -v "^/dev/" |
  grep -v "^socket:" |
  grep -v "^pipe:" |
  grep -v "^anon_inode:" |
  sed "s/^/${pid}	/"
done |
sort -n -k 1
