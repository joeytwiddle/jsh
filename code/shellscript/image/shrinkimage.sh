#!/bin/sh
set -e

[ -z "$SHRINKTO" ] && SHRINKTO="10%"

for filename
do
  shrunken_filename="$filename.smaller.jpg"
  verbosely convert "$filename" -quality 60% -geometry "2073600@>" "$shrunken_filename"
  #del "$filename"
done
