#!/bin/sh
set -e

which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

# See also: shrinkimage

find "$@" -iname "*.PNG" -or -iname "*.JPG" -or -iname "*.JPEG" |

grep -v -F ".smaller." |
grep -v -F ".shrunken." |
grep -v -F ".keep_high_res." |

sort |

while read filename
do
	#file_size=$(stat -c '%s' "$filename")
	#if [ "$file_size" -lt 250000 ]
	#then
	#	echo "Skipping $filename because size $file_size < 250000"
	#	continue
	#fi

	shrunken_filename="$filename.smaller.jpg"

	# == Resizing ==
	# -geometry "1600x1600>"
	# "[width]x[height]>" resizes the image so that the largest axis is no larger than specified.

	# -geometry "1638400@>"
	# -geometry "2073600@>"
	# "[pixels]@" resizes the image to have (approximately) the given number of pixels.
	# This helps to preserve the content of long/thin images, which would otherwise be significantly shrunk.
	# We still use ">" so that the image will not be enlarged if it was originally smaller.
	# 1638400 = 1280x1280 = 1600x1024
	# 1920000 = 1600x1200
	# 2048000 = 1600x1280
	# 2073600 = 1920x1080 = "Full HD" aka 1080p

	# == Quality ==
	# For PNGs of game screenshots, 80% showed loss in text quality (weaker contrast), 90% looked ok, 95% showed little compression.

	# When scaling down vector images, -scale may be preferable to -geometry, because it is linear rather than cubic.  Cubic can introduce unwanted ringing at high-contrast edges.  Incidentally, -scale is also faster.
	# However when scaling down photos, -geometry (or -resize) may be preferable, to keep the edges sharp.

	# When I don't care that much about the images, I want to keep them for posterity, but I really want to save space.
	#verbosely convert "$filename" -quality 60% -geometry "1920000@>" "$shrunken_filename"

	# For photos I want to keep at reasonably good quality, but I don't need them to be perfect.
	verbosely convert "$filename" -quality 80% -geometry "2073600@>" "$shrunken_filename"

	touch -r "$filename" "$shrunken_filename"

	# If the process actually made the file larger, then copy the old one over the "shrunken" one.
	if [ "$(stat -c '%s' "$shrunken_filename")" -gt "$(stat -c '%s' "$filename")" ]
	then
		echo "The convered image was larger!  So sticking with the original."
		cp -af "$filename" "$shrunken_filename"
	fi

	#del "$filename"
done
