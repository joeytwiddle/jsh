# mencoder crouching\ tiger,\ hidden\ dragon.avi -o re_encoded.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=5

# MP_CLIP="-ss 1:00 -endpos 0:20"

for VIDEOFILE
do

	# mencoder "$@" -o re_encoded.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=6 || exit

	mencoder "$VIDEOFILE" -o "$VIDEOFILE"-simple.avi -of avi -oac lavc -ovc lavc -lavcopts vqscale=6 $MP_CLIP || exit

done

# SIZE=`filesize re_encoded.avi`
# echo "$SIZE"
# if [ "$SIZE" -gt 671088640 ] && [ "$SIZE" -lt 737148928 ] ## 640-703Mb
# then del brazil.avi
# else del re_encoded.avi
# fi

## Another: 
# E convertê-lo para divx (o arquivo source é o input12.avi, no exemplo):
# 
# mencoder -forceidx input12.avi -lavcopts vcodec=mpeg4:vhq:vbitrate=131 -ovc lavc -vop scale=352:240 -oac mp3lame -lameopts vbr=3:abr=128:q=0:aq=0 -o output12.avi

