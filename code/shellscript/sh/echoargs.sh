#!/bin/sh

#  omitting in word1 word2 ... from for command means "use
#  arg. vector for word list"

N=0

for word
do
  # Works on Hwi.  What about Unix?
  N=$(($N+1));
  # echo "           $N:   >${word}<"
  printf ">{$word}< "
done
echo "(total $N)"
