# SKIP_FIRST_PASS=true
# PREVIEW="-ss 0:00:00 -endpos 0:15"
# POSTPROC="-de"
# POSTPROC="de/al"
# POSTPROC="al" ## automatic brightness/contrast
# POSTPROC="de/dr/al/lb" ## deringing, automatic brightness/contrast and linear blend deinterlacer
# POSTPROC="de/hb/vb/dr/al/lb" ## Horizontal and vertical deblocking, deringing, automatic brightness/contrast and linear blend deinterlacer
# POSTPROC="de/tn:1:2:3" ## Enable default filters & temporal denoiser.
# POSTPROC="de/hb/vb/dr/al/lb/tn:1:2:3" ## Everything!

INPUT="$1"
LANG=en

## TODO: cleanup /if/ doing first pass

## First pass to generate audio/frameno file:
if [ ! "$SKIP_FIRST_PASS" ]
then
	del frameno.avi divx2pass.log
	echo "############################ Audio pass"
	echo "## mencoder \"$INPUT\" $PREVIEW -ovc frameno -o frameno.avi -oac mp3lame -lameopts abr:br=128 -alang \"$LANG\""
	mencoder "$INPUT" $PREVIEW -ovc frameno -o frameno.avi -oac mp3lame -lameopts abr:br=128 -alang "$LANG" | tee /tmp/sizes.log
	echo
fi

## Obtain recommended bitrate:
if [ "$BITRATE" ]
then echo "Using user supplied bitrate $BITRATE"
else
	BITRATE=`tail -50 /tmp/sizes.log | grep "Recommended video bitrate for 700MB CD: " | afterlast ": "`
	if [ "$BITRATE" -gt 2 ] && [ "$BITRATE" -lt 9999999 ]
	then :
	# else BITRATE=2616
	else BITRATE=1000
	fi
fi

# BITRATE=`expr "$BITRATE" '*' 25 / 100`
# BITRATE=`expr "$BITRATE" '*' 28 / 100`

# PREVIEW="-ss 0:13:30 -endpos 0:15"

# NEWSIZE="352:264" ## for Step into Water
# BITRATE=`expr "$BITRATE" / 2` ## For BotB
# EXTRAOPTS="-ni -nobps"                      ## For Dune sync I hope!
# EXTRAOPTS="$EXTRAOPTS -fps 29.9 -ofps 29.9" ## For Dune sync I hope!
# EXTRAOPTS="-aspect 352:264"
# BITRATE=4000 ## For Step into Liquid

echo "Using bitrate $BITRATE"

## Second and third passes (preview or final):
# Postprocessing: -vf pp=hb/vb/dr/al/lb   
addfilter () {
	if [ "$FILTERS" ]
	then FILTERS="$FILTERS,"
	else FILTERS="-vf "
	fi
	FILTERS="$FILTERS$1=$2"
}
[ "$NEWSIZE" ] && addfilter scale "$NEWSIZE"
[ "$POSTPROC" ] && addfilter pp "$POSTPROC"
for PASS in 1 2
do
	[ $PASS = 1 ] && OUTPUT=/dev/null || OUTPUT=out.avi ## Does it really matter if the output of the first pass goes into that file?
	# OUTPUT=preview.avi
	# vqmin=2:vqmax=31:
	ENCODING="-oac copy -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=$BITRATE:vhq:vpass=$PASS"
	echo "############################ Pass $PASS / 2"
	echo "## mencoder \"$INPUT\" -o \"$OUTPUT\" $ENCODING $PREVIEW $FILTERS $EXTRAOPTS"
	nice -15 mencoder "$INPUT" -o "$OUTPUT" $ENCODING $PREVIEW $FILTERS $EXTRAOPTS \
		|| exit
	echo
done

