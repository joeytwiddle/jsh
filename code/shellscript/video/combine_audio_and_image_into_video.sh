#!/usr/bin/env sh
audio="$1"
image="$2"
video="$3"

# avconv is really slow.
# Feel free to try with avidemux or anything else.

# -ss seek (we need to do this after the -i because otherwise seek in single image fails!)
# -t duration
# -y force overwrite
# The -shortest below might not play well with these
#seek_option="-ss 25"
#duration_option="-t 1"

# For this I recommend: video="something.mpeg"
#avconv -loop 1 -i "$image" -i "$audio" "$video"
#avconv -loop 1 -i "$image" -i "$audio" -b:a 128k -shortest "$video"

# For this I recommend: video="something.mp4"
avconv -y -loop 1 -i "$image" -i "$audio" -c:v libx264 -c:a aac -strict experimental -b:a 192k $seek_option $duration_option -shortest "$video"
