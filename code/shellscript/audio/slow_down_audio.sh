#!/bin/bash
. require_exes ffmpeg

set -e

infile="$1"
outfile="$1.mp3"

# -vn - drop audio
ffmpeg -i "$infile" -filter:a "atempo=0.75" "$outfile"
