#!/bin/sh

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

    outfile="$file.cropped.png"

    convert "$file" -crop "${width}x${height}+${left}+${top}" $autocrop "$outfile"

    touch -r "$file" "$outfile"

    if [ -n "$DEL" ]
    then del "$file"
    fi
done

if [ -z "$DEL" ]
then jshinfo "If you are happy with the results, and want to delete the originals, rerun with: DEL=1 batch_crop_images ..."
fi
