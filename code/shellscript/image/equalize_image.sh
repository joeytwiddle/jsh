#!/bin/sh

for image_file
do
  out_file="${image_file}.equalized.jpg"

  # This messes up the color balance
  #convert "${image_file}" -equalize "${out_file}"

  # http://www.fmwconcepts.com/imagemagick/redist/index.php
  redist -s uniform -m RGB "${image_file}" "${out_file}"

  touch -r "$image_file" "${out_file}"
done
