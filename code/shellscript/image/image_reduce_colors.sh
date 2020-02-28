#!/bin/sh

[ -z "$NUM_COLORS" ] && NUM_COLORS=256

for input_file
do
    if echo "$input_file" | grep "\.reduced_colors\." >/dev/null
    then continue
    fi

    output_file="$input_file.reduced_colors.png"

    echo "$input_file -> $output_file"

    # NOTE: +dither aka -dither None is suitable if the image has no gradients, but
    # if the image DOES have gradients, then remove it, or use -dither FloydSteinberg or -dither Riemersma

    # -depth 8 is not needed

    convert "$input_file" +dither -colors "$NUM_COLORS" -quality 100 "$output_file"
done
