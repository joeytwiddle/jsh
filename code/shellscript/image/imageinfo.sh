#!/bin/sh
for FILE
do convert -verbose "$FILE" /tmp/imageinfo-$$.jpg
done
rm -f /tmp/imageinfo-$$.jpg
