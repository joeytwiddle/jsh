#!/bin/sh
# Just an example of redirecting pipes to deal with while shell separation.
exec 3<&0
exec <datafile
i=0
while read line;do
  i=`expr $i + 1`
  done
  echo $i
  exec 0<&3
  read dummy
  echo dummy = $dummy
