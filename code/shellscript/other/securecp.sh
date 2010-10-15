#!/bin/sh
for X in $1; do
  echo scp -B $X $2 $3
  scp $X $2
  if test "$?" = "0"; then
    echo "Copied OK"
  else
    echo "Error"
  fi
done
