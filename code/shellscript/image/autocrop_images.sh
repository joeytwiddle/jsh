#!/bin/sh

for image_file
do
    if [ -f "${image_file}" ]
    then
        out_file="${image_file}.autocropped.png"
        convert "${image_file}" -trim -fuzz 90% "${out_file}"
        touch -r "${image_file}" "${out_file}"
    else
        echo "Not a file: ${image_file}" >&2
    fi
done
