#!/bin/sh

# One easy way to get the values for left, top, width and height is to draw a rectangle in GIMP, and then look at `Window > Dockable Dialogues > Tool Options` on the left.

set -e

left="$1" ; shift
top="$1" ; shift
width="$1" ; shift
height="$1" ; shift

# After cropping, perform an autocrop?
#autocrop="-trim"

if [ "$*" = "" ]
then exec batch_crop_images "$left" "$top" "$width" "$height" ./*
fi

for file in "$@"
do
    if echo "$file" | grep "\.cropped\." >/dev/null
    then continue
    fi

    #outfile="$file.cropped.png"

    # If you also want to reduce the size at the same time (faster than compressing large pngs)
    outfile="$file.cropped.smaller.jpg"
    # -quality 80%

    verbosely convert "$file" -crop "${width}x${height}+${left}+${top}" $autocrop -quality 80% "$outfile"

    touch -r "$file" "$outfile"

    if [ -n "$DEL" ]
    then del "$file"
    fi
done

if [ -z "$DEL" ]
then jshinfo "If you are happy with the results, and want to delete the originals, rerun with: DEL=1 batch_crop_images ..."
fi
