#!/bin/sh
for X in "$@"; do
  DIR=`dirname "$X"`
  FILE=`filename "$X"`
  cd "$DIR"
  mkdir -p horrid
  echo "\"$DIR/$FILE\" -> $DIR/horrid/"
  mv "$FILE" horrid
done
