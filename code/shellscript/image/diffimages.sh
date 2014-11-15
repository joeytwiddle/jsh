#!/bin/bash
. require_exes composite

image1="$1"
image2="$2"

outFile="$3"
[ -z "$outFile" ] && outFile=difference.png

if [ -z "$image1" ] || [ -z "$image2" ]
then cat << !

Usage: diffimages <image1> <image2> [<output_file>]

If no output image is specified, output will be saved in difference.png .

!
exit 0
fi

# I could not get diffing to work well with transparent images, so let's just make them non-transparent!
kill_transparency=true
if [ -n "$kill_transparency" ]
then
	#bgcol=darkred
	bgcol=black
	#bgcol=white
	#bgcol=gray
	filled_image1="$image1.filled_by_diffimages.png"
	filled_image2="$image2.filled_by_diffimages.png"
	convert "$image1" -background $bgcol -flatten "$filled_image1"
	convert "$image2" -background $bgcol -flatten "$filled_image2"
	image1="$filled_image1"
	image2="$filled_image2"
fi

# Produces black for no difference:
composite "$image1" "$image2" -compose difference "$outFile"
# Just made a mess when I fed them transparent images:
#convert "$image1" "$image2" \( -clone 0 -clone 1 -compose difference -composite -threshold 0 \) -delete 1 -alpha off -compose copy_opacity "$outFile"

#convert "$image2" "$image1" -alpha off +repage \
#	\( -clone 0 -clone 1 -compose difference -composite -threshold 0 \) \
#	\( -clone 0 -clone 2 -compose multiply -composite \) \
#	-delete 0,1 +swap -alpha off -compose copy_opacity -composite -trim +repage \
#	"$outFile"

if [ -n "$kill_transparency" ]
then
	rm -f "$filled_image1"
	rm -f "$filled_image2"
fi

