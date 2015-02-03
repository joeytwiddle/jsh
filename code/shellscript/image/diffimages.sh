#!/bin/bash
. require_exes composite

image1="$1"
image2="$2"

outFile="$3"
[ -z "$outFile" ] && outFile=difference.png

if [ $# != 2 ] && [ $# != 3 ]
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
	bgcol=darkred
	#bgcol=darkmagenta
	#bgcol=black
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

# Check if the result is completely black (indicating no difference)
#if convert "$outFile" txt: | grep -v '^#' | grep -v '#000000  black$' >/dev/null
info=`identify -verbose -unique "$outFile"`
if grep '^  Colors: 1$' <<< "$info" >/dev/null && grep -A1 '^  Histogram:$' <<< "$info" | grep '^.*: (  0,  0,  0) #000000 gray(0)$' >/dev/null
then
	echo 'Images are identical.'
	true
else
	# It might be nice to get a measure of the difference here, e.g. %age of pixels which are not black.
	echo 'There are differences.'
	false
fi

