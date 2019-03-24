#!/bin/sh

for image_file
do
    if [ -f "${image_file}" ]
    then
        out_file="${image_file}.reduced.png"
        # NOTE: +dither is suitable if the image has no gradients, but
        # if the image DOES have gradients, then remove it, or use -dither FloydSteinberg or -dither Riemersma
        # -depth 8 is not needed
        convert "${image_file}" +dither -colors 64 -quality 100 "${out_file}"
        touch -r "${image_file}" "${out_file}"
    else
        echo "Not a file: ${image_file}" >&2
    fi
done
