# jsh-ext-depends: mencoder
# mencoder input.avi -o re_encoded.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=5

[ -n "$PREVIEW" ] && MP_CLIP="-ss 1:00 -endpos 0:10"

# MP_MEET_STANDARD="-vf scale=720:480 -ofps 30" ## NTSC
# MP_MEET_STANDARD="-vf scale=720:576 -ofps 25" ## PAL
# MP_MEET_STANDARD="-vf scale=360:286 -ofps 25" ## half (well quarter!) PAL

## Couldn't open codec mp2, br=224
#	1) audio must be 16 bits per sample, so add -channels 2
#	2) Not all sampling rates are good, so try to resample:
#	-srate 48000 or -srate 22050 or -srate 32000.

[ -n "$SRATE" ] || SRATE=48000
[ -n "$VQSCALE" ] || VQSCALE=6 ## Lower is higher quality
[ -n "$OFPS" ] || OFPS=25

## Be gentle:
which renice >/dev/null && renice -n 10 -p $$
which ionice >/dev/null && ionice -c 3 -p $$

for VIDEOFILE
do
  ## Alternative: vqscale=6:acodec=mp2
  # mencoder "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=6 || exit
  mencoder -srate "$SRATE" -ofps "$OFPS" $MP_MEET_STANDARD "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=$VQSCALE $MP_CLIP $MP_EXTRA_OPTS || exit
done

## Another:
# mencoder -forceidx input12.avi -lavcopts vcodec=mpeg4:vhq:vbitrate=131 -ovc lavc -vop scale=352:240 -oac mp3lame -lameopts vbr=3:abr=128:q=0:aq=0 -o output12.avi
## TODO: Try replacing mpeg4 with msmpeg4v2

