#!/bin/sh
set -e

for image_file
do
    if printf "%s\n" "$image_file" | grep "\.autocropped\." >/dev/null
    then continue
    fi

    if [ -f "$image_file" ]
    then
        out_file="${image_file}.autocropped.png"
        convert "$image_file" -trim -fuzz 90% "$out_file"
        touch -r "$image_file" "$out_file"
        if [ -n "$DEL" ]
        then del "$image_file"
        fi
    else
        echo "Not a file: ${image_file}" >&2
    fi
done

if [ -z "$DEL" ]
then jshinfo "If you are happy with the results, and want to delete the originals, rerun with: DEL=1 autocrop_images ..."
fi
