#!/bin/sh

extra=""

if [ -n "$PREVIEW" ]
then
    preview_offset="-ss 300"
    preview_duration="-t 10"
fi

[ -z "$CRF" ] && [ -z "$ANIMATION" ] && CRF=15
[ -z "$CRF" ] && [ -n "$ANIMATION" ] && CRF=23

# It is recommended to always choose a tuning method, for better performance than the defaults.  https://github.com/HandBrake/HandBrake/issues/634
# Possible tunings are: film animation grain stillimage psnr ssim fastdecode zerolatency
# Source: https://superuser.com/questions/564402/explanation-of-x264-tune

# A good default
tuning="-tune film"
[ -n "$ANIMATION" ] && tuning="-tune animation"
[ -n "$GRAINY" ] && tuning="-tune grain"

# Recommended filters for animation
# We need a recent ffmpeg for these filters to work
[ -n "$ANIMATION" ] && video_filters='-vf pp=hb/vb/dr/fq|8'

# We put $preview_offset before the -i, because although it is not so accurate, it is a lot faster!

## Be gentle:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

for input
do
    output="$input.reenc-x264.crf-$CRF.mp4"

    rm -f "$output"

    # -y overwrite output file

    #avconv \
    #  $preview_offset \
    #  -i "$input" \
    #  $preview_duration \
    #  -c:v libx264 -c:a copy \
    #  -b 500k -aq 96 \
    #  -y \
    #  "$output"

    # -flags aq \
    # -qscale 0.5 \
    # Didn't have any affect: -global_quality 10 \
    # -x265-params  crf=22:qcomp=0.8:aq-mode=1:aq_strength=1.0:qg-size=16:psy-rd=0.7:psy-rdoq=5.0:rdoq-level=1:merange=44 \
    # Made the size much larger (but maybe this is good for previewing quality?): -preset ultrafast \

    # I was using this for a while.  It was ok.
    # Lower crf is better quality
    # Recommended for animation, but not working for me:
    #avconv \
    docker run -v $PWD:/mounted jrottenberg/ffmpeg \
      -stats \
      $preview_offset \
      -i /mounted/"$input" \
      $preview_duration \
      -c:v libx264 -c:a copy \
      $video_filters \
      -preset slow \
      $tuning \
      -crf "$CRF" \
      $extra \
      /mounted/"$output"

done
