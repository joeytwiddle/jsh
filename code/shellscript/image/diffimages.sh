#!/bin/bash

# Disabled because not very portable
#. require_exes composite

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
	echo 'There are differences.'
	total_pixels=`grep '^    Pixels: ' <<< "$info" | sed 's+.*: ++'`
	# BUG: If there are many differences (e.g. Colors: 5844) then no Histogram section is shown.
	black_pixels=`grep -A1 '^  Histogram:$' <<< "$info" | grep ' #000000 black$' | sed 's+^ *++ ; s+:.*++'`
	non_black_pixels=$((total_pixels - black_pixels))
	#difference_percentage=`expr '(' $non_black_pixels '*' 200 + 1 ')' / $total_pixels / 2`
	difference_percentage=`echo "scale=2; $non_black_pixels * 100 / $total_pixels" | bc | sed 's+^\.+0.+'`
	echo "The two images differ by $difference_percentage% ($non_black_pixels pixels)."
	false
fi

