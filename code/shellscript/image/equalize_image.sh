#!/usr/bin/env bash
set -e

for image_file
do
  if printf "%s\n" "$image_file" | grep '\.equalized\.' >/dev/null
  then continue
  fi

  #out_file="${image_file}.equalized.jpg"
  out_file="${image_file}.equalized.png"

  # This can mess up the color balance
  # As with redist, this can produce whited out parts
  #convert "$image_file" -equalize "$out_file"

  # Does better with colour balance
  #convert "$image_file" -normalize "$out_file"
  # Tweak for some dark images I was working with
  convert "$image_file" -gamma 1.4 -normalize "$out_file"

  # From: http://www.fmwconcepts.com/imagemagick/redist/index.php
  # But something the result has parts of the image whited out, and sometimes it displays an error message (but proceeds).
  #redist -s uniform -m RGB "$image_file" "$out_file"

  touch -r "$image_file" "$out_file"

  [ -n "$DEL" ] && del "$image_file" || true
done
