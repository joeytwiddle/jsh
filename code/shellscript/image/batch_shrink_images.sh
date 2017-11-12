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

	verbosely convert "$filename" -geometry "2073600@>" -quality 50% "$shrunken_filename"

	touch -r "$filename" "$shrunken_filename"

	# If the process actually made the file larger, then copy the old one over the "shrunken" one.
	if [ "$(stat -c '%s' "$shrunken_filename")" -gt "$(stat -c '%s' "$filename")" ]
	then cp -af "$filename" "$shrunken_filename"
	fi

	#del "$filename"
done
