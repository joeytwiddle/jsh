#!/bin/bash
. require_exes composite

outFile="$3"
[ -z "$outFile" ] && outFile=difference.png

# Produces black for no difference:
composite "$1" "$2" -compose difference "$outFile"
# Just made a mess when I fed them transparent images:
#convert "$1" "$2" \( -clone 0 -clone 1 -compose difference -composite -threshold 0 \) -delete 1 -alpha off -compose copy_opacity "$outFile"
