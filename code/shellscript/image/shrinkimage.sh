#!/bin/sh
set -e

# TODO: There is a conflict here: If the image is already low res, then I want high quality to keep the details.  But if the image is high res, then I often want to keep it high res but lower the quality, because that will reduce the storage size whilst still producing a fairly good result when zoomed out.

# If you choose webp instead of jpg, then you can also change quality from 80% to 90% and still get a slightly smaller result.
# As a rule of thumb:
# - webp is better when shrinking a PNG, especially vector art or computer screenshots, but NOT for PNGs of nature
# - jpg makes more sense when the image is from a compressed video, because the artefacts are already there!
# - jpg may also offer a better visual impression, as long as you are not intending to zoom in

# With WEBP you can maybe drop the quality by 5-10% compared to JPG.
# But with webp, note that:
# - For complex images, you want QUALITY=95, otherwise the details will get smoothed out.
#   (Lower quality JPEGs tend to keep the details, but degrade everything equally.  But WEBP smooths over the details.)
# - For less complex images, you can drop the QUALITY to perhaps 80 or even 50, and still get reasonable fidelity.
# - Smaller images need higher quality than larger images.
#
# TODO: We could try experimenting with more options, to try to tune the quality automatically.

if [ -z "$EXT" ]
#then EXT="jpg"
then EXT="webp"
fi

if [ -z "$QUALITY" ]
then QUALITY="95"
fi

# When converting to webp, imagemagick can take some specific options:
# https://imagemagick.org/script/webp.php

# When using LOSSLESS, the QUALITY option has a reduced effect on the output.  QUALITY=5 seems to be good anyway!
more_options=""
if [ -n "$LOSSLESS" ]
then more_options="${more_options} -define webp:lossless=true"
fi

# This ensures text colours do not become dull when converting to WEBP
more_options="${more_options} -define webp:use-sharp-yuv=true"

maybe_crop=""
# Add -fuzz 5% -trim for autocropping with fuzziness, but beware this might also crop non-letterboxed images too!
if [ -n "$AUTOCROP" ]
then maybe_crop="-fuzz 0% -trim"
fi

# "[width]x[height]>" resizes the image so that the largest axis is no larger than specified.
# "[pixels]@" resizes the image to have (approximately) the given number of pixels.
# This helps to preserve the content of long/thin images, which would otherwise be significantly shrunk.
# We still use ">" so that the image will not be enlarged if it was originally smaller.
#geometry="1638400@>" # 1280x1280 = 1600x1024 (0.64)
#geometry="1920000@>" # 1600x1200 (0.75, 4:3)
geometry="2073600@>" # 1920x1080 (0.5625, 16:9) = "Full HD" aka 1080p
#geometry="2304000@>" # 1920x1200 (0.625, 8:5)
#geometry="2211840@>" # 2048x1080 (0.52734375, 256:135) = "DCI 2K (native resolution)"
#geometry="4096000@>" # 2560x1600 (0.625, 8:5) = 13 inch MacBook
#geometry="4259840@>" # 2560x1664 (0.65, 20;13) = M2 MacBook Air

for filename
do
  if echo "$filename" | grep "\.smaller\.\(jpg\|webp\)$" >/dev/null
  then continue
  fi

  shrunken_filename="${filename}.smaller.${EXT}"

  verbosely convert "$filename" $maybe_crop -quality "$QUALITY" $more_options -geometry "$geometry" "$shrunken_filename"

  touch -r "$filename" "$shrunken_filename"

  # If the process actually made the file larger, then copy the old one over the "shrunken" one.
  if [ "$(stat -c '%s' "$shrunken_filename")" -gt "$(stat -c '%s' "$filename")" ]
  then
          echo "The convered image was larger!  So sticking with the original."
          verbosely cp -af "$filename" "$shrunken_filename"
  fi

  [ -n "$DEL" ] && del "$filename"
done

if [ -z "$DEL" ]
then jshinfo "Re-run with DEL=1 to remove originals"
fi
