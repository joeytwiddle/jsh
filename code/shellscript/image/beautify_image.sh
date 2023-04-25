#!/bin/sh

# This does a pretty good job..
#equalize_image "$@"
#exit "$?"

for input_file
do
  output_file="${input_file}.beautified.jpg"

  # Add more contrast.  Can be too strong.
  #convert "$input_file" -contrast "$output_file"

  # Undesirable, will change colours!
  #convert "$input_file" -equalize "$output_file"

  #convert "$input_file" -normalize "$output_file"

  # Usually quite a mild change, but better than nothing
  convert "$input_file" -auto-gamma "$output_file"

  # A simple linear stretch to the contrast, so that low is 0 and high is 255
  #convert "$input_file" -auto-level "$output_file"
  # Burn the specified percentage of pixels to full black or white
  # This burning can give the feeling of a bright sunny day
  # At 0% I think this is the same as auto-level
  #convert "$input_file" -contrast-stretch 20%x14% "$output_file"
  # But it is probably better to use linear-stretch instead of contrast-stretch, because it reduces artefacts caused by histogram binning
  #convert "$input_file" -linear-stretch 20%x14% "$output_file"
  #convert "$input_file" -linear-stretch 5%x5% "$output_file"
  #convert "$input_file" -linear-stretch 2%x2% "$output_file"
  # The exact value to use depends ont the input image

  # OK
  # From: https://imagemagick.org/discourse-server/viewtopic.php?t=16558
  # This did lighten some areas a bit.  It also did a lot of sharpening.
  #convert "$input_file" \
  #  \( -clone 0 -blur 0x60 \) \
  #  \( -clone 0 -clone 1 +swap -compose mathematics \
  #  -set option:compose:args "0,1,-1,0.5" -composite \
  #  -matte -channel A -evaluate set 40% +channel \) \
  #  \( -clone 0 -blur 0x3 \) \
  #  \( -clone 0 -clone 3 +swap -compose mathematics \
  #  -set option:compose:args "0,1,-1,0.5" -composite \
  #  -matte -channel A -evaluate set 50% +channel \) \
  #  \( -clone 0 -clone 2 -compose hardlight -composite \
  #  -clone 4 -compose overlay -composite \) \
  #  -delete 0-4 "${input_file}.beautified1.jpg"

  # GOOD
  # From: https://imagemagick.org/script/clahe.php
  #magick "$input_file" -clahe 25x25%+128+3 "${input_file}.beautified2.jpg"
  #magick "$input_file" -virtual-pixel mirror -clahe '300x300+128+3!' "${input_file}.beautified3.jpg"
  #magick "$input_file" -virtual-pixel mirror -clahe '900x900+128+3!' "${input_file}.beautified4.jpg"

  touch -r "$input_file" "$output_file"

  [ -n "$DEL" ] && del "$image_file" || true
done
exit
