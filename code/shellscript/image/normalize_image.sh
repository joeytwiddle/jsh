#!/bin/sh

infile="$1"

outfile="$(printf "%s" "$infile" | sed 's+\(.*\)\.+\1.enhanced.+')"
[ "$infile" = "$outfile" ] && outfile="$infile".enhanced.png

convert -contrast "$infile" "$outfile"
# Maybe
#convert -enhance -contrast "$infile" "$outfile"
# Unlikely!  Even on its own, -equalize will tend to "invent" ugly colours when processing dark images.
#convert -enhance -equalize -contrast "$infile" "$outfile"

touch -r "$infile" "$outfile"
