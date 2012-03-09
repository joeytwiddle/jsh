#!/bin/sh
TARGET_SIZE=`getxwindimensions`

ANGLE=`seq 240 5 360 | chooserandomline`
if [ $((RANDOM%2)) = 0 ]
then ANGLE="-$ANGLE"
fi

## Why is it so SLOW?!  Generating a smaller image at the start helps a bit.
## (As well as producing a less noisty plasma.)

# convert -size 1280x1024 plasma:fractal -blur 0x8 -swirl 180 /tmp/plasma_swirl.png
convert -size 320x256 plasma:fractal -blur 0x3 -swirl 180 /tmp/plasma_swirl.png
# convert -size 320x256 plasma:fractal -radial-blur 5 -swirl 180 /tmp/plasma_swirl.png
convert /tmp/plasma_swirl.png -resize "$TARGET_SIZE" /tmp/plasma_swirl.png
xsetbg /tmp/plasma_swirl.png

## DONE: Since the result looks like the centre is "deeper" into the scene, we
## should not blur the centre so much!

