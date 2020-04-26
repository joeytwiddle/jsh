#!/bin/sh
set -e

[ -z "$SHRINKTO" ] && SHRINKTO="10%"

for filename
do
  if echo "$filename" | grep "\.smaller\.jpg$" >/dev/null
  then continue
  fi

  shrunken_filename="$filename.smaller.jpg"
  #shrunken_filename="$filename.smaller.webp"
  # With webp you can maybe drop the quality by 5-10%

  # 1638400 = 1280x1280 = 1600x1024 (0.64)
  # 1920000 = 1600x1200 (0.75)
  # 2073600 = 1920x1080 (0.5625) = "Full HD" aka 1080p
  # 2304000 = 1920x1200 (0.625)

  # Reasonable quality (for images that were already fuzzy) <80kb
  #verbosely convert "$filename" -quality 95% -geometry "1638400@>" "$shrunken_filename"

  # Good quality, but not perfect if you zoom in (for beautiful images you want to preserve) >200kb
  verbosely convert "$filename" -trim -quality 60% -geometry "2304000@>" "$shrunken_filename"

  # Not lossless but close enough
  #verbosely convert "$filename" -quality 95% -geometry "2304000@>" "$shrunken_filename"

  touch -r "$filename" "$shrunken_filename"

  [ -n "$DEL" ] && del "$filename"
done

if [ -z "$DEL" ]
then jshinfo "Re-run with DEL=1 to remove originals"
fi
