#!/bin/sh
set -e

which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

# See also: shrinkimage

#find "$@" -iname "*.PNG" -or -iname "*.JPG" -or -iname "*.JPEG" |
find "$@" -iname "*.PNG" |

fgrep -v ".smaller." |
fgrep -v ".reduced." |
fgrep -v ".shrunken." |
fgrep -v ".keep_high_res." |

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
	#  307200 = 480x640
	# 1638400 = 1280x1280 = 1600x1024
	# 1920000 = 1600x1200
	# 2048000 = 1600x1280
	# 2073600 = 1920x1080 = "Full HD" aka 1080p

	# == Quality ==
	# For PNGs of game screenshots, 80% showed loss in text quality (weaker contrast), 90% looked ok, 95% showed little compression.

	# When scaling down vector images (e.g. icons or cartoons), -scale may be preferable to -geometry, because it is linear rather than cubic.  Cubic can introduce unwanted ringing at high-contrast edges.  Incidentally, -scale is also faster.
	# However when scaling down photos, -geometry (or -resize) may be preferable, to keep the edges sharp.
	# See image_reduce_colors
	#shrunken_filename="$filename.reduced.png"
	#verbosely convert "$filename" -colors 256 -quality 100 -scale "1920000@>" "$shrunken_filename"
	# But dithering is problematic.  On some images 32 colors is fine, and saves space.
	# But on some images, it chooses the wrong colors (e.g. it cares more about the gradients in the background than it does about the details of the face in the foreground).  In that case, 256 colours should be used, and the space saving is rather poor.
	# In my experience, this actually provided far better compression
	#verbosely convert "$filename" -quality 97% -geometry "1920000@>" "$shrunken_filename"

	# Medium size, low quality (for really low importance or low quality images)
	#verbosely convert "$filename" -quality 40% -geometry "1638400@>" "$shrunken_filename"

	# When I don't care that much about the images, I want to keep them for posterity, but I really want to save space.
	#verbosely convert "$filename" -quality 60% -geometry "1920000@>" "$shrunken_filename"

	# Small size but high quality (to save space, but not produce an ugly image)
	#verbosely convert "$filename" -quality 90% -geometry "307200@>" "$shrunken_filename"

	# Reasonable size, reasonable quality, for snapshots of TV dramas
	verbosely convert "$filename" -quality 70% -geometry "1638400@>" "$shrunken_filename"

	# Good size good quality
	#verbosely convert "$filename" -quality 90% -geometry "1920000@>" "$shrunken_filename"

	# For autocropping: -fuzz 0% -trim
	# Add -fuzz 5% -trim for autocropping with fuzziness, but beware this might also crop non-letterboxed images too!

	touch -r "$filename" "$shrunken_filename"

	# If the process actually made the file larger, then copy the old one over the "shrunken" one.
	if [ "$(stat -c '%s' "$shrunken_filename")" -gt "$(stat -c '%s' "$filename")" ]
	then
		echo "The convered image was larger!  So sticking with the original."
		cp -af "$filename" "$shrunken_filename"
	fi

	[ -n "$DEL" ] && del "$filename"
done

if [ -z "$DEL" ]
then jshinfo "Re-run with DEL=1 to remove originals"
fi
