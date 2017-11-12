#!/bin/bash

# See also: http://stackoverflow.com/questions/5132749/diff-an-image-using-imagemagick?rq=1

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
info=$(convert "$outFile" -fill magenta +opaque "rgb(0,0,0)" -format %c histogram:info:)
black_pixels=$(grep ' black$' <<< "$info" | sed 's+^ *++ ; s+:.*++')
non_black_pixels=$(grep ' magenta$' <<< "$info" | sed 's+^ *++ ; s+:.*++')
total_pixels=$((black_pixels + non_black_pixels))
if [[ -n "$black_pixels" ]] && [[ "$black_pixels" = "$total_pixels" ]]
then
	echo 'The images are identical.'
	true
else
	#difference_percentage=`expr '(' $non_black_pixels '*' 200 + 1 ')' / $total_pixels / 2`
	difference_percentage=`echo "scale=2; $non_black_pixels * 100 / $total_pixels" | bc | sed 's+^\.+0.+'`
	echo "The images differ by $difference_percentage% ($non_black_pixels pixels)."
	false
fi

