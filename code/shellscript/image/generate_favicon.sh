#!/bin/bash

if [ -z "$1" ] || [ "$1" = --help ]
then
    echo
    echo "generate_favicon <image_file>"
    echo
    echo "  will create a multi-layer favicon.ico file in the current folder"
    echo
    exit
fi

input_file="$1" ; shift

convert "$input_file" -define icon:auto-resize=64,48,32,16 favicon.ico

# For other approaches, see https://gist.github.com/pfig/1808188
